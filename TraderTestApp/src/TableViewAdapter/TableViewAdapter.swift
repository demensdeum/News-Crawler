//
//  TableViewAdapter.swift
//  TraderTestApp
//
//  Created by Ilia Prokhorov on 16/10/2018.
//  Copyright © 2018 Ilia Prokhorov. All rights reserved.
//

import UIKit

class TableViewAdapter: NSObject {
    
    private weak var tableView: UITableView?
    private var items = [TextParserResultItem]()
    
    let cellIdentifier = "ResultTableViewCell"
    
    init(tableView: UITableView) {
        
        super.init()
        
        self.tableView = tableView
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        
    }
 
    // MARK: - Interface
    
    public func insert(result: [TextParserResultItem]) {

            guard result.count > 0 else { return }
            
            var insertedIndexes = [IndexPath]()
        
            for i in 0...result.count - 1 {
                let row = items.count
                let index = IndexPath(row: row + i, section: 0)
                insertedIndexes.append(index)
            }
        
            items.append(contentsOf: result)
        
            tableView?.beginUpdates()
            tableView?.insertRows(at: insertedIndexes, with: .fade)
            tableView?.endUpdates()
    }
    
    public func clear() {
        items.removeAll()
        tableView?.reloadData()
    }
}

extension TableViewAdapter: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

}

extension TableViewAdapter: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numberOfRowsInSection = self.items.count
        
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = cell(tableView, forRowAt: indexPath)
        return reusableCell
    }
    
    private func cell(_ tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let resultItem = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ResultTableViewCell
        cell.fill(resultItem: resultItem)
        
        return cell
    }
}
