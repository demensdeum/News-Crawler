//
//  ViewController.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 15/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var fileURLTextField: UITextField?
    @IBOutlet weak var regexpTextField: UITextField?
    
    @IBOutlet weak var placeholderButton: UIButton?
    @IBOutlet weak var findButton: UIButton?
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView?
    
    private var presenter: Presenter?
    
    private var alert: UIAlertController?
    private var alertPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tableView = tableView else { showAlert("Internal error #1"); return }
        
        presenter = Presenter.init(viewController: self, tableView: tableView)
        
        presenter?.placeholderButton = placeholderButton
        presenter?.fileURLTextField = fileURLTextField
        presenter?.regexpTextField = regexpTextField
        presenter?.activityIndicatorView = activityIndicatorView
        
        placeholderButton?.titleLabel?.lineBreakMode = .byWordWrapping
        placeholderButton?.titleLabel?.textAlignment = .center
        
        placeholderButton?.setTitle(NSLocalizedString("PLACEHOLDER_TEXT", comment: ""), for: .normal)
        findButton?.setTitle(NSLocalizedString("FIND_BUTTON_TITLE", comment: ""), for: .normal)
        
        fileURLTextField?.placeholder = NSLocalizedString("URL_PLACEHOLDER", comment: "")
        regexpTextField?.placeholder = NSLocalizedString("SEARCH_PLACEHOLDER", comment: "")
    }
    
    // MARK: - IBAction
    
    @IBAction func findDidPress(sender: UIButton) {
        presenter?.findButtonDidPress()
    }
    
    @IBAction func didPressRunTest(sender: UIButton) {
        presenter?.didPressRunTest()
    }
    
    // MARK: - Interface
    
    public func showAlert(_ text: String) {
        
        guard alertPresented == false else { return }
        alertPresented = true
        
        alert = UIAlertController(title: "",
                                      message: text,
                                      preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: { [weak self] (UIAlertAction) in
                                            self?.alertPresented = false
        })
        alert?.addAction(defaultAction)
        
        DispatchQueue.main.async(execute: { [weak self] in
            if let alert = self?.alert {
                self?.present(alert, animated: true)
                self?.alertPresented = true
            }
        })
    }
}
