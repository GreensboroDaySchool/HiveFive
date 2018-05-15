//
//  ServerTransport.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

public protocol ServerTransport {
    func onSetup(server: Hive5Server)
    func onShutdown(server: Hive5Server)
}
