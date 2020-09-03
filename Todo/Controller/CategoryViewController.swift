//
//  CategoryViewController.swift
//  Todo
//
//  Created by David Owen on 8/26/20.
//  Copyright © 2020 David Owen. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
//    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.reloadData()
        
    }
    
    //MARK: - UITableViewController Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            if let color = UIColor(hexString: category.color) {
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.backgroundColor = color
            }
        } else {
            cell.textLabel?.text = "No categories created yet!"
        }
        return cell
    }
    
    //MARK: - UI Interactions
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Create New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let category = textField.text, !category.isEmpty {
                let newCategory = Category()
                newCategory.name = category
                newCategory.color = UIColor.randomFlat().hexValue()
                
                do {
                    try self.realm.write {
                        self.realm.add(newCategory)
                    }
                } catch {
                    print("Error in adding new category: \(error)")
                }
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in}
        alert.addAction(cancelAction)
        alert.addAction(action)
        alert.addTextField { (field) in
            field.placeholder = "New Category"
            textField = field
        }
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ViewItemsSegue", sender: self)
    }
    
    //MARK: - Data handling
    func loadCategories() {
        categories = realm.objects(Category.self)
    }
    
    //MARK: - Handle Segue to Items
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            if let category = categories?[indexPath.row] {
                destinationVC.selectedCategory = category
            }
        }
    }
    
    //MARK: - Override deleteEntity from parent class
    override func deleteEntity(at indexPath: IndexPath) {
        do {
            try realm.write {
                if let category = categories?[indexPath.row]{
                    realm.delete(category.items)
                    realm.delete(category)
                }
            }
        } catch {
            print("Error deleting category: \(error)")
        }
    }
}
