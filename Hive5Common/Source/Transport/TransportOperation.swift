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
public protocol HFTransportModel: Codable {
    var op: String { get }
}

//public extension HFTransportModel {
//    public static var createRoom: HFTransportCreateRoom.Type { return HFTransportCreateRoom.self }
//    public static var guestDidJoin: HFTransportGuestDidJoin.Type { return HFTransportGuestDidJoin.self }
//}

public protocol DecodingDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

public func constructHFModel(_ message: Data, type: String, with decoder: DecodingDecoder) throws -> HFTransportModel {
    switch type {
    case "createRoom": return try decoder.decode(HFTransportCreateRoom.self, from: message)
    case "join": return try decoder.decode(HFTransportJoin.self, from: message)
    case "didJoin": return try decoder.decode(HFTransportDidJoin.self, from: message)
    case "leave": return try decoder.decode(HFTransportLeave.self, from: message)
    case "sync": return try decoder.decode(HFTransportSynchronize.self, from: message)
    case "requestSync": return try decoder.decode(HFTransportRequestSynchronize.self, from: message)
    case "gameStateUpdate": return try decoder.decode(HFTransportGameStateUpdate.self, from: message)
    default: throw HFCodingError.decodingError("unknown operaotr '\(type)' from the message")
    }
}

/**
 [Client] -> [Server]
 
 This message is sent from the client to the server when it requests
 the server to create a new room and set the client to the host. The
 server should response with a "didJoin" message when succeed, or a
 "leave" message when failed
 */
public struct HFTransportCreateRoom: HFTransportModel {
    public let op = "createRoom"
    
    public var hostName: String
    public var hostColor: Color
}

/**
 [Client] -> [Server]
 
 This message is sent to the server when the client request to join a room.
 The server should respond either with a "didJoin" message or a "leave"
 message.
 */
public struct HFTransportJoin: HFTransportModel {
    public let op = "join"
    
    public var name: String
    public var roomNumber: Int
    public var token: Int? = nil
}

/**
 [Server] -> [Client]
 
 Sent by the server. This message indicates that the client has successfully
 joined a game.
 */
public struct HFTransportDidJoin: HFTransportModel {
    public let op = "didJoin"
    
    public var token: Int
    public var roomNumber: Int
    public var color: Color
}

/**
 [Server] -> [Client]
 
 A notification the server send to the host when a guest has joined the game.
 */
public struct HFTransportGuestDidJoin: HFTransportModel {
    public let op = "guestDidJoin"
    
    public var guestName: String
    public var guestColor: Color
}

/**
 [Server] -> [Client]
 [Client] -> [Server]
 
 This message can be send by either the client or the server. This message
 indicates the client is about to leave the server and close the connection.
 */
public struct HFTransportLeave: HFTransportModel {
    public let op = "leave"
    
    public var reason: String
}

/**
 [Server] -> [Client]
 
 This message is send by the server to update the client's game board.
 */
public struct HFTransportSynchronize: HFTransportModel {
    public let op = "sync"
    
    public var hive: Hive
}

/**
 [Client] -> [Server]
 
 This message is send by the client when it wants to synchronize the hive
 with the server.
 */
public struct HFTransportRequestSynchronize: HFTransportModel{
    public let op = "requestSync"
}

/**
 [Server] -> [Client]
 
 This message is send to the clients when the state of the game that the
 player is in has been updated.
 */
public struct HFTransportGameStateUpdate: HFTransportModel {
    public let op = "gameStateUpdate"
    
    public var newState: GameState
    public var reason: String
}
