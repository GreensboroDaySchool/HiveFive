//
//  Client.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

class Client: Hashable, CustomStringConvertible {
    var name: String
    var color: Color?
    var game: Game?
    lazy var token = ObjectIdentifier(self).hashValue
    
    var description: String { return "\(name) - \(color == nil ? "undefined color" : color!.description)" }
    
    var isHost: Bool { return game?.host == self }
    
    weak var server: Hive5Server?
    
    init(name: String) {
        self.name = name
    }

    func kick(for reason: String){
        try? send(HFTransportLeave(reason: reason))
        server?.on(clientLeave: self)
    }
    
    func didJoin(game: Game, as color: Color) {
        self.game = game
        self.color = color
        try? send(HFTransportDidJoin(token: token, roomNumber: game.id, color: color))
    }
    
    //This is where the Client class handles all the messages sent to it
    func onMessage(_ message: HFTransportModel){
        switch message {
        case is HFTransportRequestSynchronize:
            guard let game = game else { debugPrint("[!] client \(self) requested to synchronize the game, but game is undefined"); break }
            try? send(HFTransportSynchronize(hive: game.hive))
        default: debugPrint("[!] unknown message '\(message.op)' passed into Client:onMessage()")
        }
    }
    
    //MARK: Implemented by Subclasses
    
    var hashValue: Int { fatalError("Client:hashValue not implemented") }
    
    func send(_ message: HFTransportModel) throws { fatalError("Client:send() not implemented") }
    
    //MARK: Static Methods
    
    static func ==(_ lhs: Client, _ rhs: Client) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
