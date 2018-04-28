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
            guard let textData = text.data(using: .utf8) else { return }
            guard let object = (try? JSONSerialization.jsonObject(with: textData, options: .init(rawValue: 0))) as? [String:Any] else { return }
            var handled = false
            self?.server.clients.forEach{
                client in
                guard handled == false else { return }
                guard let client = client as? SwifterClient else { return }
                if client.session?.hashValue == session.hashValue {
                    client.onWebSocketData(object)
                    handled = true
                }
            }
            if !handled { self?.handleNewSession(session, with: object) }
        }, { _,_ in })
    }
    
    /**
     Handles new sessions, if there hasn't been one.
     
     In this method, we handle two types of new sessions
     - Recovered session: with an op of "reJoin" and a token sent to the client used to verify its identity "token"
     - New session: with an op of "join" and a room number "room"
     */
    func handleNewSession(_ client: WebSocketSession, with message: [String:Any]){
        guard let op = message["op"] as? String else { return }
        switch op {
        case "join":
            guard let room = message["room"] as? Int else { client.error(); return }
            let name = (message["name"] as? String) ?? "A Guest"
            let clientInstance = SwifterClient(client, name: name)
            debugPrint("[*] Client \(try! client.socket.peername()) joined the game")
            let _ = server.on(newClient: clientInstance, in: room)
        case "reJoin":
            guard let token = message["token"] as? UInt32 else { client.error(); return }
            guard let player = server.clients.reduce(SwifterClient?.none, {
                if let p = $1 as? SwifterClient {
                    if p.token == token { return p }
                }
                return $0
            }) else { client.error("player with token not found"); return }
            player.onRejoin(client)
        default: break
        }
    }
    
    func onSetup(server: Hive5Server){
        self.server = server
    }
    
    func onShutdown(server: Hive5Server) {
        print("[*] Stopping service socket...")
        self.http.stop()
    }
}
