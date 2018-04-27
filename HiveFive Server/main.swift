//
//  main.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import Swifter
import Dispatch

let semaphore = DispatchSemaphore(value: 0)
let http = HttpServer()
let transport = SwifterServerTransport(from: http)
let server = Hive5Server(with: transport)

print("[*] Starting Hive 5 server...")

do{
    try http.start(19374, forceIPv4: false, priority: .default)
    server.up();
    print("[*] Server running on port \(try http.port())")
    semaphore.wait()
} catch {
    print("[!] error \(error)")
    semaphore.signal()
    server.down()
}
