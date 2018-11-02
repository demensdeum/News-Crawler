//
//  FileWriteService.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 16/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import Foundation

protocol FileWriteServiceDelegate: class {
    
    func fileWriteService(service: FileWriteService, didFinishWith error: Error?)
    
}

class FileWriteService {
    
    private var path: String
    private var fileURL: URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            let error = NSError.error(domain: "FileWriteService", text: "Write file internal error", code: 3)
            self.handle(error: error)
            return nil
        }
        let fileURL = dir.appendingPathComponent(self.path)
        return fileURL
    }
    public weak var delegate: FileWriteServiceDelegate?
    private var cancelled = false
    let operationQueue = OperationQueue()
    
    // MARK: - Life-Cycle
    
    init(path: String) {
        self.path = path
        operationQueue.name = "File writes operation queue"
        operationQueue.maxConcurrentOperationCount = 1
        
        clear()
    }
    
    // MARK: - Interface
    
    public func append(lines: [String]) {
        
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            guard let fileURL = self.fileURL else { return }
            var error = self.createFileIfNeeded(fileURL)
            guard error == nil else { if let error = error { self.handle(error: error) }; return }
            error = self.writeLines(lines, at: fileURL)
            guard error == nil else { if let error = error { self.handle(error: error) }; return }
        }
    }
    
    public func clear() {
        operationQueue.cancelAllOperations()
        operationQueue.addOperation { [weak self] in
            self?.cancelled = true
            guard let self = self else { return }
            guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                let error = NSError.error(domain: "FileWriteService",
                                          text: "Write file error",
                                          code: 3)
                self.handle(error: error)
                return
            }
            
            let fileURL = dir.appendingPathComponent(self.path)
            
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    // MARK: - Internal
    
    private func handle(error: Error) {
        DispatchQueue.main.async { [weak self] in
            if let self = self {
                self.delegate?.fileWriteService(service: self, didFinishWith: error)
            }
        }
    }
    
    private func createFileIfNeeded(_ fileURL: URL) -> Error? {
        if FileManager.default.fileExists(atPath: fileURL.path) == false {
            do {
                try "".write(to: fileURL, atomically: true, encoding: .utf8)
            }
            catch {
                let error = NSError.error(domain: "FileWriteService",
                                          text: error.localizedDescription,
                                          code: 1)
                return error
            }
        }
        return nil
    }
    
    private func writeLines(_ lines: [String], at fileUrl: URL) -> Error? {

        guard let outputStream = OutputStream(toFileAtPath: fileUrl.path, append: true) else {
            let error = NSError.error(domain: "FileWriteService", text: "Write file internal error", code: 4)
            return error
        }
        
        outputStream.open()
        
        for line in lines {
            let preparedLine = line + "\n"
            guard let data = preparedLine.data(using: .utf8) else {
                let error = NSError.error(domain: "FileWriteService", text: "Write file internal error", code: 5)
                return error
            }
            
            outputStream.write(data: data)
        }
        
        outputStream.close()
        
        return nil
    }
}
