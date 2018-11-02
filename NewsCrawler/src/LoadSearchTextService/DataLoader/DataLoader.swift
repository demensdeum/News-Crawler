//
//  DataLoader.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 15/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import Foundation

protocol DataLoaderDelegate: class {
    
    func dataLoader(loader: DataLoader, didLoad data: Data)
    func dataLoader(loader: DataLoader, didFinishWith error: Error?)
    
}

class DataLoader: NSObject {
    
    private var url: URL
    weak var delegate: DataLoaderDelegate?
    private var session: URLSession?
    private let operationQueue = OperationQueue()
    
    // MARK: - Life-Cycle
    
    init(url: URL) {
        self.url = url
    }
    
    // MARK: - Interface
    
    public func load() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCache = nil
        
        self.session = URLSession(configuration: sessionConfiguration,
                                  delegate: self,
                                  delegateQueue: operationQueue)
        
        let request = URLRequest(url: url)
        if let task = self.session?.dataTask(with: request) {
            task.resume()
        }
    }
    
    public func cancel() {
        session?.invalidateAndCancel()
    }
}

extension DataLoader: URLSessionDelegate {

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else { return }
        
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
        
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        delegate?.dataLoader(loader: self, didFinishWith: error)
    }
}

extension DataLoader: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        delegate?.dataLoader(loader: self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate?.dataLoader(loader: self, didFinishWith: error)
    }
}
