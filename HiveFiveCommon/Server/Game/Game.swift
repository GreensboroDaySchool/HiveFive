//
//  Game.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

class Game{
    let host: Client
    let id: Int
    let hive: Hive
    
    var guest: Client?
    var state: GameState
    
    init(host: Client, id: Int) {
        self.host = host
        self.id = id
        self.guest = nil
        self.hive = Hive()
        self.state = .waiting
    }
    
    func end(for reason: String) {
        guest?.kick(for: reason)
        host.kick(for: reason)
    }
}

//To the extend of the original gameEnded, we have more states
enum GameState{
    case waiting //We are still waiting for another player to join
    case playing //The game is on
    case ended //The game has ended
}
