//
//  NonblockingTableViewUpdater.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 16/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import Foundation

protocol NonblockingTableViewUpdaterDelegate: class {
    
    func nonblockingTableViewUpdater(updater: NonblockingTableViewUpdater, wantsToInsert result: [TextParserResultItem])
    
}

class NonblockingTableViewUpdater {
    
    public weak var delegate: NonblockingTableViewUpdaterDelegate?
    private var pollingTimer: Timer?
    private var result = [TextParserResultItem]()
    private var lastInsertedIndex = -1
    private let queue = DispatchQueue(label: "com.demensdeum.newscrawlertestapp.dispatch.queue")

    public var uuid = ""
    
    // MARK: - Life-Cycle
    
    init() {
        uuid = NSUUID().uuidString
    }
    
    deinit {
        DispatchQueue.main.async { [weak self] in
            self?.cancel()
        }
    }
    
    // MARK: - Interface
    
    public func start() {
        guard Thread.isMainThread == true else { fatalError("Trying to start table view update from background thread") }
        
        pollingTimer = Timer.scheduledTimer(timeInterval: 0.00001,
                                               target: self,
                                               selector: #selector(poll(timer:)),
                                               userInfo: nil,
                                               repeats: true)
        pollingTimer?.fire()
    }
    
    public func cancel() {
        guard Thread.isMainThread == true else { fatalError("Trying to cancel table view update from background thread") }

        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    public func insert(result: TextParserResult) {
        guard Thread.isMainThread == false else { fatalError("Trying to insert results from main thread, must be called from background thread for performance") }
        
        queue.sync {
            self.result.append(contentsOf: result.resultItems)
        }
    }
    
    // MARK: - Polling
    
    @objc private func poll(timer: Timer) {
        guard Thread.isMainThread == true else { fatalError("Trying to call table view poll update from background thread") }

        var items = [TextParserResultItem]()
        
        queue.sync {
            
            while lastInsertedIndex < result.count - 1 && items.count < 40 {
                lastInsertedIndex += 1
                items.append(result[lastInsertedIndex])
            }
        }
        
        if items.count > 0 {
            delegate?.nonblockingTableViewUpdater(updater: self,
                                                  wantsToInsert: items)
        }
    }
    
}
