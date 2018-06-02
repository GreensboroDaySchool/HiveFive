//
//  WebSocketClient.swift
//  Hive5Server
//
//  Created by Xule Zhou on 6/2/18.
//

import Foundation
import WebSocket
import Hive5Common

public class WebSocketClient: Client {
    
}

public struct PreJoinWebSocketSession: CustomStringConvertible {
    internal var websocket: WebSocket
    internal weak var transport: WebSocketTransport?
    
    private(set) public var description: String
    
    init(_ websocket: WebSocket, transport: WebSocketTransport, description: String){
        self.websocket = websocket
        self.transport = transport
        self.description = description
        
        websocket.onText{
            (_: WebSocket, message: String) in
            do{
                let model = try constructHFModel(from: message)
                
                
            }catch{
                HFLog.warn("Error while parsing message on pre-join session: \(error)")
            }
        }
    }
}
