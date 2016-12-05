//
//  DateUtils.swift
//  Imaginex
//
//  Created by Mac Mini on 10/12/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

class DateUtils {
    static func fromString(_ text: String) -> Date {
        // No format? use default
        return fromString(text, format: "yyyy-MM-dd HH:mm:ss")
    }

    static func fromString(_ text: String, format: String) -> Date {
        var date = Date(timeIntervalSince1970: 0)
        if !text.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            date = formatter.date(from: text)!
        }
        return date
    }
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let text = formatter.string(from: self)
        return text
    }
    
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let text = formatter.string(from: self)
        return text
    }
}

