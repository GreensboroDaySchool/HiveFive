//
//  TransportOperation.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

enum TransportOperation {
    case createRoom(roomNumber: UInt16)
    case join(name: String)
    case didJoin(color: Color)
    case guestDidJoin(guestColor: Color, guestName: String)
    case leave(reason: String)
    
    //Just a generic error
    case error(message: String)
}
