//
//  Client.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

class Client: Hashable {
    var name: String
    var color: Color?
    var game: Game?
    
    var isHost: Bool { return game?.host == self }
    
    weak var server: Hive5Server?
    
    init(name: String) {
        self.name = name
    }

    func kick(for reason: String){
        try? send(.leave(reason: reason))
        server?.on(clientLeave: self)
    }
    
    func didJoin(game: Game, as color: Color) {
        self.game = game
        self.color = color
        try? send(.didJoin(color: color))
    }
    
    //This is where the Client class handles all the messages sent to it
    func onMessage(_ op: TransportOperation){
        
    }
    
    func error(_ message: String = "invalid operation"){ try? send(.error(message: message)) }
    
    //MARK: Implemented by Subclasses
    
    var hashValue: Int { fatalError("Client:hashValue not implemented") }
    
    func send(_ op: TransportOperation) throws { fatalError("Client:send() not implemented") }
    
    //MARK: Static Methods
    
    static func ==(_ lhs: Client, _ rhs: Client) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
