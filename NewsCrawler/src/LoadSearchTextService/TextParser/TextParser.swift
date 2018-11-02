//
//  TextParser.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 15/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import Foundation

struct TextParserResultItem {
    let text: String
}

struct TextParserResult {
    let resultItems: [TextParserResultItem]
    let error: Error?
}

class TextParser {
    static func parse(text: String, regexp: String) -> TextParserResult {
        
        guard text.count > 0 else {
            
            let error = NSError.error(domain: "TextParser",
                                      text: NSLocalizedString("EMPTY_TEXT_SEARCH_ERROR", comment: ""),
                                      code: 1)
            
            return TextParserResult(resultItems: [], error: error)
        }
        
        var regexpExpression: Regex? = nil
        
        do {
            regexpExpression = try Regex(string: regexp)
        }
        catch {
        }
        
        guard let regexpExpressionGuarded = regexpExpression else {
            
            let error = NSError.error(domain: "TextParser",
                                      text: NSLocalizedString("INCORRECT_TEXT_SEARCH_ERROR", comment: ""),
                                      code: 2)
            
            return TextParserResult(resultItems: [], error: error)
        }
        
        let matches = regexpExpressionGuarded.allMatches(in: text)

        var resultItems = [TextParserResultItem]()
        
        for match in matches {
            let resultItem = TextParserResultItem(text: match.matchedString)
            resultItems.append(resultItem)
        }
        
        return TextParserResult(resultItems: resultItems, error: nil)
    }
}
