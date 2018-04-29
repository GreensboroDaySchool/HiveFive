//
//  ServerTransportImpl.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import Swifter

/**
 WebSocket ServerTransport
 
 The server side transportation provider implemented with the Swifter framework.
 
 Why use WebSocket? For one reason, WebSocket is a widely used standard
 for bidirectional communication supported by many platforms. Thus if we
 want to rewrite this game into a web version, this protocol will ensure
 maximum compatibility. The communication protocol is simple, and can be
 wrapped around with TLS to ensure maximum. Also, many public CDNs support
 WebSockets, while basically none of them supports native TCP transports.
 
 */
class SwifterServerTransport: ServerTransport {
    let http: HttpServer
    weak var server: Hive5Server!
    
    init(from server: HttpServer){
        self.http = server
        
        server["/game"] = websocket({ [weak self] (session, text) in
            do{
                guard let textData = text.data(using: .utf8) else { throw HFCodingError.decodingError("unable to convert original text message to Data") }
                let decodedMessage = try SwifterServerTransport.decode(from: textData)
                var handled = false
                self?.server.clients.forEach{
                    client in
                    guard handled == false else { return }
                    guard let client = client as? SwifterClient else { return }
                    if client.session?.hashValue == session.hashValue {
                        client.onMessage(decodedMessage)
                        handled = true
                    }
                }
                if !handled { self?.handleNewSession(session, with: decodedMessage) }
            }catch{ debugPrint("error while handling incoming message: \(error)") }
        }, { _,_ in })
    }
    
    /**
     Handles new sessions, if there hasn't been one.
     
     In this method, we handle two types of new sessions
     - Recovered session: with an op of "reJoin" and a token sent to the client used to verify its identity "token"
     - New session: with an op of "join" and a room number "room"
     
     */
    func handleNewSession(_ session: WebSocketSession, with message: HFTransportModel){
        do{
            switch message {
            case let message as HFTransportJoin:
                //Check for previous instantiated client if the token is present
                if let token = message.token {
                    let player = server.clients.reduce(Client?.none){
                        return $1.token == token ? $1 : $0
                    }
                    if let swifterPlayer = player as? SwifterClient {
                        swifterPlayer.onRejoin(session)
                        break
                    }
                }
                //If not, treat the join message as creating a new game session
                let client = SwifterClient(session, name: message.name)
                debugPrint("[*] Player '\(client.name)' \(client.socketPeerName) joined the server.")
                let _ = server.on(newClient: client, in: message.roomNumber)
            case let message as HFTransportCreateRoom:
                let client = SwifterClient(session, name: message.hostName)
                client.color = message.hostColor
                debugPrint("[*] Player '\(client.name)' \(client.socketPeerName) joined the server.")
                let _ = server.createGame(host: client)
            default:
                try server.on(unclaimedMessage: message){ try session.writeHFMessage($0) }
            }
        }catch{ debugPrint("[!] Error while handling new session: \(error)") }
    }
    
    func onSetup(server: Hive5Server){
        self.server = server
    }
    
    func onShutdown(server: Hive5Server) {
        print("[*] Stopping service socket...")
        self.http.stop()
    }
    
    static func decode(from message: Data) throws -> HFTransportModel {
        guard let deserialized = try JSONSerialization.jsonObject(with: message, options: .init(rawValue: 0)) as? [String:Any]
            else { throw HFCodingError.decodingError("unable to decode message") }
        guard let op = deserialized["op"] as? String
            else { throw HFCodingError.decodingError("unable to decode message operator") }
        let decoder = JSONDecoder()
        
        switch op {
        case "createRoom": return try decoder.decode(HFTransportCreateRoom.self, from: message)
        case "join": return try decoder.decode(HFTransportJoin.self, from: message)
        case "didJoin": return try decoder.decode(HFTransportDidJoin.self, from: message)
        case "leave": return try decoder.decode(HFTransportLeave.self, from: message)
        case "sync": return try decoder.decode(HFTransportSynchronize.self, from: message)
        case "requestSync": return try decoder.decode(HFTransportRequestSynchronize.self, from: message)
        case "gameStateUpdate": return try decoder.decode(HFTransportGameStateUpdate.self, from: message)
        default: throw HFCodingError.decodingError("unknown operaotr '\(op)' from the message")
        }
    }
}
