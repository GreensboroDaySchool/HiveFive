//
//  Swifter+Serializers.swift
//  HiveFive Server
//
//  Created by Marcus Zhou on 4/26/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Swifter
import Foundation

extension WebSocketSession {
    func json(_ data: [String:Any]){
        guard let data = (try? JSONSerialization.data(withJSONObject: data, options: .init(rawValue: 0))) else { return }
        guard let string = String(data: data, encoding: .utf8) else { return }
        writeText(string)
    }
    
    func error(_ message: String = "invalid message"){ json(["op": "error", "message": message]) }
}
