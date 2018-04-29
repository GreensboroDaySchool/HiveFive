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
    var socketPeerName: String {
        guard let socket = session?.socket else { return "" }
        guard let addr = try? socket.peername() else { return "" }
        return addr
    }
    
    init(_ s: WebSocketSession, name: String) {
        session = s
        super.init(name: name)
    }
    
    func onRejoin(_ newSession: WebSocketSession){
        debugPrint("Player \(self) rejoined the game")
        session = newSession
        try? send(HFTransportDidJoin(token: token, roomNumber: game!.id, color: color!))
    }
    
    override func send(_ message: HFTransportModel) throws { try session?.writeHFMessage(message) }
}
