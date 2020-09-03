//
//  ItemViewController.swift
//  TodoList
//
//  Created by David Owen on 8/26/20.
//  Copyright © 2020 David Owen. All rights reserved.
//
import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class ItemViewController: SwipeTableViewController {
    //    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: Results<Item>?
    let realm = try! Realm()
    let sortProperties = [SortDescriptor(keyPath: "complete", ascending: true), SortDescriptor(keyPath: "title", ascending: true)]
    var selectedCategory : Category? {
        didSet{
            getItemsForCategory()
        }
    }
    
    override func viewDidLoad() {
        if let category = selectedCategory {
            navigationItem.title = category.name
        }
        super.viewDidLoad()
    }
    
    //MARK: - UITableViewController Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.complete ? .checkmark : .none
            let darkenPercentage = CGFloat(indexPath.row) / CGFloat(items!.count)
            if let backgroundColor = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: darkenPercentage) {
                cell.backgroundColor = backgroundColor
                cell.textLabel?.textColor = ContrastColorOf(backgroundColor, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No items created yet!"
        }
        
        return cell
    }
    
    //MARK: - UI Interactions
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let item = textField.text, !item.isEmpty {
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = item
                        self.selectedCategory?.items.append(newItem)
                    }
                } catch {
                    print("Error when adding new item : \(error)")
                }
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in}
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            field.placeholder = "New item"
            textField = field
        }
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        var item = items[indexPath.row]
        
        if let item =  items?[indexPath.row] {
            do {
                try realm.write {
                    item.complete = !item.complete
                }
            } catch {
                print("Error when updating item: \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Data handling
    func getItemsForCategory() {
        items = selectedCategory?.items
            .sorted(byKeyPath: "complete", ascending: true)
    }
    
    //MARK: - Override deleteEntity from parent class
    override func deleteEntity(at indexPath: IndexPath) {
        do {
            try realm.write {
                if let item = items?[indexPath.row]{
                    realm.delete(item)
                }
            }
        } catch {
            print("Error deleting category: \(error)")
        }
    }
    
    override func createCheckAction(at indexPath: IndexPath) -> SwipeAction? {
        let checkAction = SwipeAction(style: .default, title: "Check") { (action, indexPath) in
            do {
                try self.realm.write{
                    if let item = self.items?[indexPath.row] {
                        item.complete = !item.complete
                    }
                }
            } catch {
                print("Error when checking off an item: \(error)")
            }
            self.tableView.reloadData()
        }
        return checkAction
    }
    
}

//MARK: - SearchBarDelegate
extension ItemViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("SEARCH")
        if let search = searchBar.text {
            updateListBasedOnSearch(text: search)
            self.tableView.reloadData()
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getItemsForCategory()
        if let search = searchBar.text {
            print("search: \(search)")
            updateListBasedOnSearch(text: search)
            self.tableView.reloadData()
        }
    }
    
    func updateListBasedOnSearch(text: String) {
        if !text.isEmpty {
            items = items?.filter("title CONTAINS[cd] %@", text).sorted(by: sortProperties)
            print("\(items)")
        }
    }
}
