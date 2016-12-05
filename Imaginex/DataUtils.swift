//
//  DataUtils.swift
//  Imaginex
//
//  Created by Mac Mini on 10/24/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

extension Dictionary {
    func toJson() -> String {
        let invalidJson = "{\"error\":\"Invalid JSON\"}"
        do {
            let json = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: json, encoding: String.Encoding.utf8) ?? invalidJson
        } catch let error as NSError {
            print(error)
            return invalidJson
        }
    }
}
