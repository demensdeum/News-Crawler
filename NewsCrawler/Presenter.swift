//
//  Presenter.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 16/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import UIKit

class Presenter: NSObject {
    
    private weak var viewController: ViewController?

    public weak var fileURLTextField: UITextField? {
        didSet {
            fileURLTextField?.returnKeyType = .next
            fileURLTextField?.delegate = self
        }
    }
    public weak var regexpTextField: UITextField? {
        didSet {
            regexpTextField?.returnKeyType = .done
            regexpTextField?.delegate = self
        }
    }
    public weak var tableView: UITableView?
    public weak var placeholderButton: UIButton?
    public weak var activityIndicatorView: UIActivityIndicatorView?
    
    private var tableViewAdapter: TableViewAdapter
    private var loadSearchTextService: LoadSearchTextService?
    
    private var loadSearchServiceUUID = ""
    
    private var fileWriteService: FileWriteService? = nil
    
    private var previousURL: URL?
    private var previousRegexp: String?
    
    init(viewController: ViewController,
         tableView: UITableView) {
        
        self.tableViewAdapter = TableViewAdapter(tableView: tableView)
        
        super.init()
        
        self.viewController = viewController
        self.tableView = tableView
        
    }
    
    // MARK: - Interface
    
    public func findButtonDidPress() {
        performSearchFind()
    }
    
    public func didPressRunTest() {
        fileURLTextField?.text = "https://news.google.com"
        regexpTextField?.text = "fear.*"
        
        performSearchFind()
    }
    
    private func cancel() {
        
        loadSearchServiceUUID = ""
        loadSearchTextService?.cancel()
        
        activityIndicatorView?.stopAnimating()
        
        fileWriteService?.clear()
        
        placeholderButton?.isHidden = true
        
        loadSearchTextService?.cancel()
        tableViewAdapter.clear()
        
        loadSearchTextService = LoadSearchTextService()
        loadSearchTextService?.delegate = self
        loadSearchServiceUUID = loadSearchTextService?.uuid ?? ""

        fileWriteService = FileWriteService(path: "results.log")
        fileWriteService?.delegate = self
        
    }
    
    private func performSearchFind() {
        
        guard let fileURLText = fileURLTextField?.text, fileURLText.count > 0 else {
            
            viewController?.showAlert(NSLocalizedString("URL_VALIDATION_ERROR", comment: ""))
            fileURLTextField?.becomeFirstResponder()
            
            return
        }
        
        guard let regexp = regexpTextField?.text, regexp.count > 0 else {
            
            viewController?.showAlert(NSLocalizedString("SEARCH_VALIDATION_ERROR", comment: ""))
            regexpTextField?.becomeFirstResponder()
            
            return
        }
        
        guard let url = URL(string: fileURLText), UIApplication.shared.canOpenURL(url) else {
            
            viewController?.showAlert(NSLocalizedString("URL_VALIDATION_ERROR", comment: ""))
            regexpTextField?.becomeFirstResponder()
            
            return
        }
        
        if url == previousURL, regexp == previousRegexp { return }
        
        cancel()
        
        previousURL = url
        previousRegexp = regexp
        
        activityIndicatorView?.startAnimating()
        loadSearchTextService?.startLoadingSearch(url: url, regexp: regexp)
    }
    
    private func handle(error: Error) {
        previousURL = nil
        previousRegexp = nil

        viewController?.showAlert(error.localizedDescription)
    }
}

extension Presenter: LoadSearchTextServiceDelegate {
    
    func loadSearchTextService(service: LoadSearchTextService, didFinishWith error: Error?) {
        if loadSearchServiceUUID == service.uuid {
            if activityIndicatorView?.isAnimating ?? false {
                activityIndicatorView?.stopAnimating()
            }
            if let error = error {
                handle(error: error)
            }
        }
    }
    
    func loadSearchTextService(service: LoadSearchTextService, result: [TextParserResultItem]) {
        if loadSearchServiceUUID == service.uuid {
            if activityIndicatorView?.isAnimating ?? false {
                activityIndicatorView?.stopAnimating()
            }
            tableViewAdapter.insert(result: result)
            
            let lines = result.map{$0.text}
            fileWriteService?.append(lines: lines)
        }
    }
    
}

extension Presenter: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == fileURLTextField {
            regexpTextField?.becomeFirstResponder()
        }
        else if textField == regexpTextField {
            textField.resignFirstResponder()
            performSearchFind()
        }
        
        return true
    }
    
}

extension Presenter: FileWriteServiceDelegate {
    
    func fileWriteService(service: FileWriteService, didFinishWith error: Error?) {
        if let error = error {
            cancel()
            handle(error: error)
        }
    }
    
}
