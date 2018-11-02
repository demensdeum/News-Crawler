//
//  LoadSearchTextService.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 16/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import Foundation

protocol LoadSearchTextServiceDelegate: class {
    
    func loadSearchTextService(service: LoadSearchTextService, result: [TextParserResultItem])
    func loadSearchTextService(service: LoadSearchTextService, didFinishWith error: Error?)
    
}

class LoadSearchTextService {
    
    private var interactiveURLParser: InteractiveURLParser?
    private var nonblockingTableViewUpdater: NonblockingTableViewUpdater?
    
    private var urlParserUUID = ""
    private var updaterUUID = ""
    
    private let queue = DispatchQueue(label: "com.newscrawlertestapp.uuid.dispatch.queue")
    
    public weak var delegate: LoadSearchTextServiceDelegate?
    
    public var uuid = ""
    
    // MARK: - Life-Cycle
    
    init() {
        uuid = NSUUID().uuidString
    }
    
    // MARK: - Interface
    
    public func startLoadingSearch(url: URL, regexp: String) {
        
        cancel()
        
        nonblockingTableViewUpdater = NonblockingTableViewUpdater()
        queue.sync {
            updaterUUID = nonblockingTableViewUpdater?.uuid ?? ""
        }
        nonblockingTableViewUpdater?.delegate = self
        nonblockingTableViewUpdater?.start()
        
        interactiveURLParser = InteractiveURLParser(url: url, regexp: regexp)
        queue.sync {
            urlParserUUID = interactiveURLParser?.uuid ?? ""
        }
        interactiveURLParser?.delegate = self
        interactiveURLParser?.load()
        
    }
    
    public func cancel() {

        queue.sync {
            urlParserUUID = ""
            updaterUUID = ""
        }
        
        interactiveURLParser?.cancel()
        nonblockingTableViewUpdater?.cancel()

    }
    
}

extension LoadSearchTextService: InteractiveURLParserDelegate {
    
    func interactiveURLParser(parser: InteractiveURLParser, didFinishWith error: Error?) {
        
        DispatchQueue.main.async{ [weak self] in
            if let error = error as NSError? {
                
                self?.cancel()
                
                if error.code == NSURLErrorCancelled {
                    // cancelled by user
                }
                else if let self = self {
                    self.delegate?.loadSearchTextService(service: self, didFinishWith: error)
                }
            }
            else if let self = self {
                self.delegate?.loadSearchTextService(service: self, didFinishWith: nil)
            }
        }
        
    }
    
    func interactiveURLParser(parser: InteractiveURLParser, didParse result: TextParserResult) {
        
        var cancelled = false
        
        queue.sync {
            cancelled = parser.uuid != urlParserUUID
        }
        
        if (!cancelled) {
            nonblockingTableViewUpdater?.insert(result: result)
        }
        
    }
}

extension LoadSearchTextService: NonblockingTableViewUpdaterDelegate {
    
    func nonblockingTableViewUpdater(updater: NonblockingTableViewUpdater,
                                     wantsToInsert result: [TextParserResultItem]) {
        
        var cancelled = false
        
        queue.sync {
            cancelled = updater.uuid != updaterUUID
        }
        
        if (!cancelled) {
            delegate?.loadSearchTextService(service: self, result: result)
        }
        
    }
}
