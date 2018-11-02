//
//  ResultTableViewCell.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 16/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var label: UILabel?
    
    // MARK: - Interface
    
    public func fill(resultItem: TextParserResultItem) {
    
        guard let data = resultItem.text.data(using: String.Encoding.unicode) else { return }
        
        try? self.label?.attributedText = NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
    
    }
    
}
