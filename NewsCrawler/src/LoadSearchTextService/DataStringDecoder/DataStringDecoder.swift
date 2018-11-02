//
//  DataStringDecoder.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 16/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import Foundation

class DataStringDecoder {
    
    private static let encodings: [String.Encoding] = [.utf8, .windowsCP1252, .windowsCP1251]
    
    public static func decode(data: Data) -> String? {
        for encoding in encodings {
            if let string = String(data: data, encoding: encoding) {
                return string
            }
        }
        
        return nil
    }
    
}
