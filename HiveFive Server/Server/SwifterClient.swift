//
//  Client.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import Swifter

class SwifterClient: Client {
    var session: WebSocketSession?
    
    var token: UInt32
    
    init(_ s: WebSocketSession, name: String) {
        //Generate a random token so the client can recover the connection afterwards
        token = arc4random()
        session = s
        
        super.init(name: name)
    }
    
    func onRejoin(_ newSession: WebSocketSession){
        session = newSession
    }
    
    func onWebSocketData(_ data: [String:Any]){
        guard let opString = data["op"] as? String else { error(); return }
        switch opString {
        case "error":
            guard let message = data["message"] as? String else { error(); return }
            let op = TransportOperation.error(message: message)
            onMessage(op)
        default: send([:])
        }
    }
    
    override func send(_ op: TransportOperation) throws {
        switch op {
        case .didJoin(color: let color): send([ "op": "didJoin", "color": color.rawValue, "token": token ])
        case .leave(reason: let reason): send([ "op": "leave", "reason": reason ])
        default: debugPrint("cannot send unimplemented operator", op)
        }
    }
    
    //Always transport data using json
    func send(_ data: [String: Any]) { session?.json(data) }
}
