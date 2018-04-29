//
//  Game.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

class Game: Equatable{
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
    
    func end(reason: String) {
        updateState(.ended, reason: reason)
    }
    
    /**
     Update the state of the game
     
     - important: always use this method instead of directly accessing the state method
     */
    func updateState(_ newState: GameState, reason: String){
        self.state = newState
        let message = HFTransportGameStateUpdate(newState: newState, reason: reason)
        try? host.send(message)
        try? guest?.send(message)
    }
    
    func on(guestJoin guest: Client){
        self.guest = guest
        guest.color = host.color!.opposite
        try? host.send(HFTransportGuestDidJoin(guestName: guest.name, guestColor: guest.color!))
        //Tell the guest to sync the hive
        try? guest.send(HFTransportSynchronize(hive: hive))
        updateState(.playing, reason: "guest joined the game")
    }
    
    static func ==(lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
}

//To the extend of the original gameEnded, we have more states
enum GameState: String{
    case waiting //We are still waiting for another player to join
    case playing //The game is on
    case ended //The game has ended
}
