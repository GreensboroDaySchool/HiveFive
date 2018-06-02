//
//  Game.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

public class Game: Equatable{
    public let host: Client
    public let id: Int
    public let hive: Hive
    
    public var guest: Client?
    private(set) public var state: GameState
    
    public init(host: Client, id: Int) {
        self.host = host
        self.id = id
        self.guest = nil
        self.hive = Hive()
        self.state = .waiting
    }
    
    public func end(reason: String) {
        updateState(.ended, reason: reason)
    }
    
    /**
     Update the state of the game
     
     - important: always use this method instead of directly accessing the state method
     */
    public func updateState(_ newState: GameState, reason: String){
        self.state = newState
        let message = HFTransportGameStateUpdate(newState: newState, reason: reason)
        try? host.send(message)
        try? guest?.send(message)
    }
    
    public func on(guestJoin guest: Client){
        self.guest = guest
        guest.color = host.color!.opposite
        updateState(.playing, reason: "guest joined the game")
    }
    
    public static func ==(lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
}

//To the extend of the original gameEnded, we have more states
public enum GameState: String, Codable{
    case waiting //We are still waiting for another player to join
    case playing //The game is on
    case ended //The game has ended
}
