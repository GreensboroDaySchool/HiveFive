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
    func writeHFMessage(_ message: HFTransportModel) throws {
        let encoder = JSONEncoder()
        var encodedData: Data = try message.encode(withJSONEncoder: encoder)
        guard let encodedString = String(data: encodedData, encoding: .utf8) else { throw HFCodingError.encodingError("unable to convert encoded json to string") }
        writeText(encodedString)
    }
}

extension HFTransportModel {
    func encode(withJSONEncoder encoder: JSONEncoder) throws -> Data {
        return try encoder.encode(self)
    }
}
