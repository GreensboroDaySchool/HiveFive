//
//  ServerTransport.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

/**
 Hive5 ServerTransport protocol
 
 Server transports handles everything related to communication, from
 encodings to establishing and recovering connections.
 
 Server transports should not send any messages to the client after
 the connections have been authenticated, nevertheless, transports
 have every right to communicate with client-side transports before
 the connection has been hand over to Hive5Server.
 */
public protocol ServerTransport {
    func onSetup(server: Hive5Server)
    func onShutdown(server: Hive5Server)
}
