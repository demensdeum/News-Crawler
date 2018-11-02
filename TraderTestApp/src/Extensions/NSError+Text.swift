//
//  NSError+Text.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 16/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import Foundation

extension NSError {
    
    static func error(domain: String, text: String, code: Int) -> NSError {
        
        let userInfo = [
            NSLocalizedDescriptionKey: NSLocalizedString(text, comment: ""),
            ];
        
        return NSError(domain: domain, code: code, userInfo: userInfo)
        
    }
    
}
