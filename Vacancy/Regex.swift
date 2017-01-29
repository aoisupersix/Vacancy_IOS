//
//  Regex.swift
//  Regex
//
//  Created by 田中葵 on 2016/11/07.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import Foundation

class Regex {
    let data: String
    
    init(_ data: String) {
        self.data = data
    }
    
    func isMatch(pattern: String) -> Bool {
        let internalRegexp: NSRegularExpression = try! NSRegularExpression( pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        let matches = internalRegexp.matches( in: self.data, options: [], range:NSMakeRange(0, self.data.characters.count) )
        return matches.count > 0
    }
    
    func matches(pattern: String) -> [String]? {
        let internalRegexp: NSRegularExpression = try! NSRegularExpression( pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        if self.isMatch(pattern: pattern) {
            let matches = internalRegexp.matches( in: self.data, options: [], range:NSMakeRange(0, self.data.characters.count) )
            var results: [String] = []
            for i in 0 ..< matches.count {
                results.append( (self.data as NSString).substring(with: matches[i].range) )
            }
            return results
        }
        return nil
    }
    
    func matches(pattern: String, range: Int) -> [String]? {
        let internalRegexp: NSRegularExpression = try! NSRegularExpression( pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        if self.isMatch(pattern: pattern) {
            let matches = internalRegexp.matches( in: self.data, options: [], range:NSMakeRange(0, self.data.characters.count) )
            var results: [String] = []
            for i in 0 ..< matches.count {
                results.append( (self.data as NSString).substring(with: matches[i].rangeAt(range)) )
            }
            return results
        }
        return nil
    }
}
