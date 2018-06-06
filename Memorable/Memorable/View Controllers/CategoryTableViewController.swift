//
//  CategoryTableViewController.swift
//  Memorable
//
//  Created by Hyun Ho Oh on 4/6/18.
//  Copyright © 2018 University of Technology Sydney. All rights reserved.
//

import UIKit
import os.log
import UserNotifications

class CategoryTableViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    // MARK: Properties
    
    var categories: [Category] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCategories = [Category]()
    
    // This property is used for memorable screen.
    var selectedCategory = Category(name: "")
    
    var notificationSettings: [NotificationSetting] = []
    
    // MARK: Private methods
    
    private func saveCategories() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(categories, toFile: Category.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Category successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save category...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadCategories() {
        if let savedCategories = NSKeyedUnarchiver.unarchiveObject(withFile: Category.ArchiveURL.path) as? [Category] {
            self.categories = savedCategories
        } else {
            os_log("Failed to laod categories...", log: OSLog.default, type: .error)
        }
    }
    
    private func setLabelForEmptyTable() {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height)))
        label.text = "No category to show.\nPlease add a category to start."
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .gray
        self.tableView.backgroundView = label
        self.tableView.separatorStyle = .none
    }
    
    private func showPopUpForAddCategory() {
        let alertController = UIAlertController(title: "New Category", message: "Enter your category name. If same category name exist, new category will not be made.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            let name = alertController.textFields?[0].text
            if let categoryName = name {
                var found = false
                for category in self.categories {
                    if categoryName == category.name {
                        found = true
                    }
                }
                if !found {
                    self.categories.insert(Category(name: categoryName), at: 0)
                    self.saveCategories()
                    super.setEditing(false, animated: false)
                    self.tableView.setEditing(false, animated: false)
                    self.tableView.reloadData()
                }
                if self.categories.count == 0 {
                    self.categories.insert(Category(name: categoryName), at: 0)
                    self.saveCategories()
                    super.setEditing(false, animated: false)
                    self.tableView.setEditing(false, animated: false)
                    self.tableView.reloadData()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Category Name"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCategories = categories.filter({( category : Category) -> Bool in
            return category.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func setSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Categories"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: Actions
    
    @IBAction func addCategoryButtonClicked(_ sender: Any) {
        self.showPopUpForAddCategory()
    }
    
    // MARK: Controller life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        self.setSearchBar()
        self.loadCategories()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.categories.count > 0 {
            self.navigationItem.leftBarButtonItem = self.editButtonItem
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.setLabelForEmptyTable()
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering() {
            return filteredCategories.count
        }
        if section == 0 {
            return self.categories.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Categories", for: indexPath)
        
        let category: Category
        if isFiltering() {
            category = self.filteredCategories[indexPath.row]
        } else {
            category = self.categories[indexPath.row]
        }

        // Configure the cell...
        
        cell.showsReorderControl = true
        cell.textLabel?.text = category.name

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    private func saveMemorables(_ memorables: [Memorable]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(memorables, toFile: Memorable.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Memorable successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save memorable...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadMemorables() -> [Memorable] {
        if let savedMemorables = NSKeyedUnarchiver.unarchiveObject(withFile: Memorable.ArchiveURL.path) as? [Memorable] {
            return savedMemorables
        } else {
            os_log("Failed to laod memorables...", log: OSLog.default, type: .error)
            return []
        }
    }
    
    func removeNotifications(memorable: Memorable) {
        // UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        // UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        var identifier: [String] = []
        identifier.append(String(memorable.id))
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifier)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifier)
    }
    
    func saveNotificationSettings() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notificationSettings, toFile: NotificationSetting.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("NotificationSetting successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save NotificationSetting...", log: OSLog.default, type: .error)
        }
    }
    
    func loadNotificationSettings() {
        if let savedNotificationSettings = NSKeyedUnarchiver.unarchiveObject(withFile: NotificationSetting.ArchiveURL.path) as? [NotificationSetting] {
            self.notificationSettings = savedNotificationSettings
        } else {
            os_log("Failed to laod NotificationSetting...", log: OSLog.default, type: .error)
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removedCategory = self.categories.remove(at: indexPath.row)
            self.saveCategories()
            
            // Delete associated memorables as well
            
            var memorables = self.loadMemorables()
            
            wrapper: while true {
                var find = false
                outerFor: for (index, memorable) in memorables.enumerated() {
                    if removedCategory.name == memorable.category {
                        self.removeNotifications(memorable: memorable)
                        memorables.remove(at: index)
                        find = true
                        break outerFor
                    }
                }
                if !find {
                    break wrapper
                }
            }
            
            self.saveMemorables(memorables)
            
            if self.categories.count == 0 {
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath.section)
                tableView.deleteSections(indexSet as IndexSet, with: .none)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedCategories = self.categories.remove(at: fromIndexPath.row)
        self.categories.insert(movedCategories, at: to.row)
        self.saveCategories()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFiltering() {
            self.selectedCategory = self.filteredCategories[indexPath.row]
        } else {
            self.selectedCategory = self.categories[indexPath.row]
        }
        self.performSegue(withIdentifier: "MemorableTableViewControllerSegue", sender: nil)
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let identifier = segue.identifier else { return }
        if identifier == "MemorableTableViewControllerSegue" {
            let memorableTableViewController = segue.destination as! MemorableTableViewController
            memorableTableViewController.category = self.selectedCategory
        }
    }

}

extension CategoryTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
