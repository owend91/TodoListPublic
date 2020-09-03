//
//  SwipeTableViewController.swift
//  Todo
//
//  Created by David Owen on 9/2/20.
//  Copyright © 2020 David Owen. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 65.0
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        var actions : [SwipeAction] = []
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteEntity(at: indexPath)
        }
        
        let checkAction = createCheckAction(at: indexPath)
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        actions.append(deleteAction)
        
        if let check = checkAction {
            check.image = UIImage(systemName: "checkmark")
            actions.append(check)
        }
        
        return actions
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    func deleteEntity(at indexPath: IndexPath) {
        
    }
    
    func createCheckAction(at indexPath: IndexPath) -> SwipeAction? {
        return nil
    }

}
