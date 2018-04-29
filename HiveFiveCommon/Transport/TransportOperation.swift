//
//  TransportOperation.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

/**
 A generic model for encoding & decoding Hive Five messages.
 */
protocol HFTransportModel: Codable {
    var op: String { get }
}

extension HFTransportModel {
    static var createRoom: HFTransportCreateRoom.Type { return HFTransportCreateRoom.self }
    static var guestDidJoin: HFTransportGuestDidJoin.Type { return HFTransportGuestDidJoin.self }
}

/**
 [Client] -> [Server]
 
 This message is sent from the client to the server when it requests
 the server to create a new room and set the client to the host. The
 server should response with a "didJoin" message when succeed, or a
 "leave" message when failed
 */
struct HFTransportCreateRoom: HFTransportModel {
    let op = "createRoom"
    
    var hostName: String
    var hostColor: Color
}

/**
 [Client] -> [Server]
 
 This message is sent to the server when the client request to join a room.
 The server should respond either with a "didJoin" message or a "leave"
 message.
 */
struct HFTransportJoin: HFTransportModel {
    let op = "join"
    
    var name: String
    var roomNumber: Int
    var token: Int? = nil
}

/**
 [Server] -> [Client]
 
 Sent by the server. This message indicates that the client has successfully
 joined a game.
 */
struct HFTransportDidJoin: HFTransportModel {
    let op = "didJoin"
    
    var token: Int
    var roomNumber: Int
    var color: Color
}

/**
 [Server] -> [Client]
 
 A notification the server send to the host when a guest has joined the game.
 */
struct HFTransportGuestDidJoin: HFTransportModel {
    let op = "guestDidJoin"
    
    var guestName: String
    var guestColor: Color
}

/**
 [Server] -> [Client]
 [Client] -> [Server]
 
 This message can be send by either the client or the server. This message
 indicates the client is about to leave the server and close the connection.
 */
struct HFTransportLeave: HFTransportModel {
    let op = "leave"
    
    var reason: String
}

/**
 [Server] -> [Client]
 
 This message is send by the server to update the client's game board.
 */
struct HFTransportSynchronize: HFTransportModel {
    let op = "sync"
    
    var hive: Hive
}

/**
 [Client] -> [Server]
 
 This message is send by the client when it wants to synchronize the hive
 with the server.
 */
struct HFTransportRequestSynchronize: HFTransportModel{
    let op = "requestSync"
}

/**
 [Server] -> [Client]
 
 This message is send to the clients when the state of the game that the
 player is in has been updated.
 */
struct HFTransportGameStateUpdate: HFTransportModel {
    let op = "gameStateUpdate"
    
    var newState: GameState
    var reason: String
}
