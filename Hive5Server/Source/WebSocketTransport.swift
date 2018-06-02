//
//  HFWebSocketTransport.swift
//  Hive5Server
//
//  Created by Xule Zhou on 6/2/18.
//

import Foundation
import WebSocket
import Hive5Common

public class WebSocketTransport: ServerTransport, HTTPServerResponder {
    
    lazy internal var gameSessionUpgrader = HTTPServer.webSocketUpgrader(shouldUpgrade: {
        if $0.url.path == "/game" { return [:] }
        return nil
    }){ (ws: WebSocket, request: HTTPRequest) in
        HFLog.debug("New session connected: \(request)")
        
    }
    
    internal var threadPool: MultiThreadedEventLoopGroup? = nil
    internal var httpServer: HTTPServer? = nil
    
    public func onSetup(server: Hive5Server) {
        threadPool = MultiThreadedEventLoopGroup(numberOfThreads: HFServerConfiguration.shared.numberOfThreads)
        
        var hostname = "localhost"
        
        if let configHostname = HFServerConfiguration.shared.hostname {
            hostname = configHostname
        } else {
            //Retrive hostname from system
            if let systemHostname = Host.current().name {
                hostname = systemHostname
            } else {
                    HFLog.error("Unable to retrive system hostname. Use localhost instead.")
            }
        }
        
        let port = HFServerConfiguration.shared.port
        
        HFLog.info("Starting event server...")
        
        do{
            httpServer = try HTTPServer.start(
                hostname: hostname,
                port: port,
                responder: self,
                reuseAddress: false,
                tcpNoDelay: true,
                upgraders: [ gameSessionUpgrader ],
                on: threadPool!){
                    error in
                    HFLog.fatal("Unable to start: \(error)")
                }.wait()
            
            HFLog.info("Service binded to \(hostname):\(port).")
        }catch{
            HFLog.fatal("Unable to start event server: \(error)")
        }
    }
    
    public func onShutdown(server: Hive5Server) {
        guard let httpServer = httpServer else { return }
        guard let threadPool = threadPool else { return }
        
        do{
            try httpServer.close().wait()
            try threadPool.syncShutdownGracefully()
        } catch{ HFLog.error("Unable to shutdown web service: \(error)") }
        self.threadPool = nil
    }
    
    //TODO: Implement stats over HTTP
    public func respond(to request: HTTPRequest, on worker: Worker) -> EventLoopFuture<HTTPResponse> {
        let response = HTTPResponse(status: .ok, body: "Hive5 Multiplayer Server")
        return worker.eventLoop.newSucceededFuture(result: response)
    }
}
