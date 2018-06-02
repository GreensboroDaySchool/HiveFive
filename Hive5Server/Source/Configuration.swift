//
//  Configuration.swift
//  Hive5Server
//
//  Created by Xule Zhou on 6/2/18.
//

import Foundation

/**
 Configurations for Hive5 Server
 */
public struct HFServerConfiguration {
    /**
     Number of threads for the event loop
     */
    public var numberOfThreads = 2
    
    /**
     The port that the server will be running on. Default to 19374
     */
    public var port = 19374
    
    /**
     Hostname of the server. If set to nil, Hive5 Server will use the system's hostname.
     */
    public var hostname: String? = nil
    
    /**
     Global instance of Hive5 Server configuration
     */
    public static var shared = HFServerConfiguration()
}
