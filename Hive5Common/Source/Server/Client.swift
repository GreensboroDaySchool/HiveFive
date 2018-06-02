//
//  Client.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

open class Client: Hashable, CustomStringConvertible {
    public var name: String
    public var color: Color?
    public var game: Game?
    public lazy var token = ObjectIdentifier(self).hashValue
    
    public var description: String { return "\(name) - \(color == nil ? "undefined color" : color!.description)" }
    
    public var isHost: Bool { return game?.host == self }
    
    private weak var server: Hive5Server?
    
    public init(name: String) {
        self.name = name
    }

    public func kick(for reason: String){
        try? send(HFTransportLeave(reason: reason))
        server?.on(clientLeave: self)
    }
    
    public func didJoin(game: Game, as color: Color) {
        self.game = game
        self.color = color
        try? send(HFTransportDidJoin(token: token, roomNumber: game.id, color: color))
        try? send(HFTransportSynchronize(hive: game.hive))
    }
    
    //This is where the Client class handles all the messages sent to it
    public func onMessage(_ message: HFTransportModel){
        switch message {
        case is HFTransportRequestSynchronize:
            guard let game = game else { HFLog.warn("[!] client \(self) requested to synchronize the game, but game is undefined"); break }
            try? send(HFTransportSynchronize(hive: game.hive))
        default: HFLog.warn("[!] unknown message '\(message.op)' passed into Client:onMessage()")
        }
    }
    
    //MARK: Implemented by Subclasses
    
    open var hashValue: Int { fatalError("Client:hashValue not implemented") }
    
    open func send(_ message: HFTransportModel) throws { fatalError("Client:send() not implemented") }
    
    //MARK: Static Methods
    
    public static func ==(_ lhs: Client, _ rhs: Client) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
