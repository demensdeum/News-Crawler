//
//  OutputStream.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 17/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import Foundation

extension OutputStream {
    func write(data: Data) {
        _ = data.withUnsafeBytes { write($0, maxLength: data.count) }
    }
}
