#if os(Linux) || os(FreeBSD)
import Glibc
#else
import Darwin
#endif

import Foundation
import Hive5Common
import WebSocket

#if DEBUG || Xcode
HFLog.logLevel = .verbose
#else
HFLog.logLevel = .info
#endif

HFLog.info("Bootstrapping Hive5 Server...")

fileprivate let transport = WebSocketTransport()
fileprivate let server = Hive5Server(with: transport)

HFLog.info("Starting server...")

public let semaphore = DispatchSemaphore(value: 0)

signal(SIGINT) {
    _ in
    semaphore.signal()
}

server.up()

HFLog.info("Done!")

semaphore.wait()

HFLog.info("Shutting down Hive5 Server...")
server.down()
