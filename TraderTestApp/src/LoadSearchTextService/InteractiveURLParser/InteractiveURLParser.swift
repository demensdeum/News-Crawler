//
//  InteractiveParser.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 15/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import Foundation

protocol InteractiveURLParserDelegate: class {
    func interactiveURLParser(parser: InteractiveURLParser, didParse result: TextParserResult)
    func interactiveURLParser(parser: InteractiveURLParser, didFinishWith error: Error?)
    
}

class InteractiveURLParser {
    
    private var regexp: String
    public weak var delegate: InteractiveURLParserDelegate?
    private var dataChunk = Data()
    private var dataString = ""
    private var dataLoader: DataLoader
    private let textParser = TextParser()
    
    public var uuid = ""
 
    init(url: URL, regexp: String) {
        
        uuid = NSUUID().uuidString
        
        self.regexp = regexp
        dataLoader = DataLoader(url: url)
        dataLoader.delegate = self
        
    }
    
    public func load() {
        dataLoader.load()
    }
    
    public func cancel() {
        dataLoader.cancel()
    }
    
    deinit {
        dataLoader.cancel()
    }
    
}

extension InteractiveURLParser: DataLoaderDelegate {
    func dataLoader(loader: DataLoader, didLoad data: Data) {
        dataChunk += data
        
        guard let decodedString = DataStringDecoder.decode(data: data) else {
            
            let error = NSError.error(domain: "InteractiveURLParser",
                                      text: NSLocalizedString("DECODE_TEXT_ERROR", comment: ""),
                                      code: 2)
            
            delegate?.interactiveURLParser(parser: self, didFinishWith: error)
            
            return
        }
        
        dataString += decodedString
        let splitted = dataString.components(separatedBy: CharacterSet.newlines)
        for splittedString in splitted {
            let result = TextParser.parse(text: splittedString, regexp: regexp)
            delegate?.interactiveURLParser(parser: self, didParse: result)
        }
        
        guard let lastSplittedString = splitted.last else {

            let error = NSError.error(domain: "InteractiveURLParser",
                                      text: NSLocalizedString("DECODE_TEXT_ERROR", comment: ""),
                                      code: 2)
            
            delegate?.interactiveURLParser(parser: self, didFinishWith: error)
            
            return
        }
        dataString = lastSplittedString
        dataChunk = Data()
    }
    
    func dataLoader(loader: DataLoader, didFinishWith error: Error?) {
        delegate?.interactiveURLParser(parser: self, didFinishWith: error)
    }
}
