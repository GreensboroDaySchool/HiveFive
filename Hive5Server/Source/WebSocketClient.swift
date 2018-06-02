//
//  WebSocketClient.swift
//  Hive5Server
//
//  Created by Xule Zhou on 6/2/18.
//

import Foundation
import WebSocket
import Hive5Common

/**
 Hive5 Server WebSocket implementation of Client
 */
public class WebSocketClient: Client {
    internal var addressDescription: String = ""
    internal var websocket: WebSocket?
    internal var transport: WebSocketTransport?
    
    internal var lastMessage: Date = Date()
    
    /**
     Took over the session from pre-join for session recovery.
     */
    internal func on(sessionRecover session: WebSocket){
        self.websocket = session
        try? send(HFTransportDidJoin(token: token, roomNumber: game!.id, color: color!))
        synchronizeHive()
    }
    
    /**
     Hands over control to WebSocketClient, register all handlers
     */
    internal func on(internalNewSessionHandover session: WebSocket, with transport: WebSocketTransport){
        self.websocket = session
        self.transport = transport
        
        session.onText{
            [weak self, addressDescription, description]
            _, messageString in
            defer{ self?.lastMessage = Date() }
            do{ self?.onMessage(try constructHFModel(from: messageString)) }
            catch{ HFLog.error("Error while processing message from \(description) (\(addressDescription)): \(error)") }
        }
    }
    
    //MARK: Implementations
    
    override public func send(_ message: HFTransportModel) throws {
        websocket?.send(try message.exportAsString())
    }
    
    override public var hashValue: Int { return ObjectIdentifier(self).hashValue }
}

/**
 Hive5 Server PreJoinWebSocketSession
 
 This class establishes connections with the clients, verifies
 pre-existing sessions, as well as communication with Hive5Server
 for various initial actions before handing over the session to
 WebSocketClient (e.g. tell the server to create rooms or join
 games).
 */
public class PreJoinWebSocketSession: CustomStringConvertible, Hashable {
    internal var websocket: WebSocket
    internal weak var transport: WebSocketTransport?
    
    private(set) public var description: String
    public var hashValue: Int { return description.hashValue }
    
    internal init(_ websocket: WebSocket, transport: WebSocketTransport, description: String){
        self.websocket = websocket
        self.transport = transport
        self.description = description
        
        HFLog.verbose("New session: \(description)")
        
        websocket.onText{
            [weak self]
            (_: WebSocket, message: String) in
            do{
                switch try constructHFModel(from: message) {
                case let message as HFTransportCreateRoom:
                    //This should never happen
                    guard let transport = self?.transport else {
                        self?.reject("server error")
                        HFLog.error("Message received from client while the host is gone.")
                        return
                    }
                    
                    let client = WebSocketClient(name: message.hostName)
                    client.on(internalNewSessionHandover: websocket, with: transport)
                    client.color = message.hostColor
                    let _ = self?.transport?.hive5Server?.createGame(host: client)
                    
                    self?.accept()
                case let message as HFTransportJoin:
                    //Try to recover the session w/ token
                    if let token = message.token {
                        if let client = transport.hive5Server?.client(withToken: token) {
                            if let wsClient = client as? WebSocketClient {
                                wsClient.addressDescription = description
                                wsClient.on(sessionRecover: websocket)
                                HFLog.debug("Client \(description) has been verified and recovered.")
                            } else {
                                HFLog.warn("It seems like client \(description) is using a different protocol to join the server. Rejected for now.")
                                HFLog.debug("Previous type: \(type(of: client)), request received by WebSocket server transport.")
                                self?.reject("Transport method mismatch")
                            }
                        } else {
                            self?.reject("Provided token does not match the one from previous session")
                            HFLog.verbose("Rejected session recovery request from \(description)")
                        }
                        return
                    }
                    
                    //This should never happen
                    guard let transport = self?.transport else {
                        self?.reject("server error")
                        HFLog.error("Message received from client while the host is gone.")
                        return
                    }
                    
                    //Join without a token
                    let newClient = WebSocketClient(name: message.name)
                    newClient.addressDescription = description
                    newClient.on(internalNewSessionHandover: websocket, with: transport)
                    let _ = self?.transport?.hive5Server?.on(newClient: newClient, in: message.roomNumber)
                    
                    self?.accept()
                case let unknown:
                    HFLog.debug("Unknown message with op code: '\(unknown.op)'")
                    HFLog.verbose("Original message: '\(unknown.description)'")
                }
            }catch{
                HFLog.warn("Error while parsing message on pre-join session: \(error)")
            }
        }
        
        websocket.onError{
            _, error in
            HFLog.warn("Communication error with pre-join session: \(error)")
        }
        
        //Release pre-join client when socket disconnects
        websocket.onClose.always {
            [weak self] in
            if self != nil {
                self!.transport?.on(clientReject: self!)
            }
        }
    }
    
    /**
     Reject the session
     */
    public func reject(_ reason: String = "Join request is rejected"){
        do{ try send(HFTransportLeave(reason: reason)) }
        catch{ HFLog.error("Unable to encode message: \(error)") }
        transport?.on(clientReject: self)
        transport = nil
    }
    
    public func accept() {
        transport?.on(clientAccept: self)
        transport = nil
    }
    
    public func send(_ model: HFTransportModel) throws {
        websocket.send(try model.exportAsString())
    }
    
    public static func == (lhs: PreJoinWebSocketSession, rhs: PreJoinWebSocketSession) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
