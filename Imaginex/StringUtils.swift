//
//  StringUtils.swift
//  Imaginex
//
//  Created by Mac Mini on 11/23/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

extension String {
    
    func matchFirst(_ pattern: String) -> String {
        let first = self.range(of: pattern, options: .regularExpression)!
        let match = self.substring(with: first)

        return match
    }
    
    func matchAll(_ pattern: String) -> [String] {
        let all = NSRange(location: 0, length: self.characters.count)
        var matches = [String]()
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let results = regex.matches(in: self, options: [], range: all)

            for item in results {
                let first = item.rangeAt(1)
                let range = self.rangeIndex(first)
                let match = self.substring(with: range)

                matches.append(match)
            }
         } catch {
            print(error)
         }
        
        return matches
    }
    
    // Painful conversion from a Range to a Range<String.Index>
    func rangeIndex(_ range: NSRange) -> Range<String.Index> {
        let index1 = self.utf16.index(self.utf16.startIndex, offsetBy: range.location, limitedBy: self.utf16.endIndex)
        let index2 = self.utf16.index(index1!, offsetBy: range.length, limitedBy: self.utf16.endIndex)
        let bound1 = String.Index(index1!, within: self)!
        let bound2 = String.Index(index2!, within: self)!
        let result = Range<String.Index>(uncheckedBounds: (bound1, bound2))
        
        return result
    }
    
}
