//
//  NotificationTableViewController.swift
//  Memorable
//
//  Created by Hyun Ho Oh on 6/6/18.
//  Copyright © 2018 University of Technology Sydney. All rights reserved.
//

import UIKit
import os.log

class NotificationTableViewController: UITableViewController {
    
    // MARK: Properties
    
    // All saved categories to display
    var categories: [Category] = []
    
    // Search controller for the search bar
    let searchController = UISearchController(searchResultsController: nil)
    
    // Filltered category list by searching
    var filteredCategories = [Category]()
    
    // Tapped category by user
    var selectedCategory = Category(name: "")
    
    // MARK: Search bar methods
    
    // Returns true if the text is empty or nil
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCategories = categories.filter({( category : Category) -> Bool in
            return category.name.lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func setSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Categories"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: Methods
    
    func loadCategories() {
        if let savedCategories = NSKeyedUnarchiver.unarchiveObject(withFile: Category.ArchiveURL.path) as? [Category] {
            self.categories = savedCategories
        } else {
            os_log("Failed to laod categories...", log: OSLog.default, type: .error)
        }
    }
    
    func setLabelForEmptyTable() {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height)))
        label.text = "No category to show.\nPlease add a category to start."
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .gray
        self.tableView.backgroundView = label
        self.tableView.separatorStyle = .none
    }
    
    // MARK: Data sources
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.categories.count > 0 {
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
        cell.textLabel?.text = category.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFiltering() {
            self.selectedCategory = self.filteredCategories[indexPath.row]
        } else {
            self.selectedCategory = self.categories[indexPath.row]
        }
        self.performSegue(withIdentifier: "NotificationDetailSegue", sender: nil)
    }
    
    // MARK: View controller life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCategories()
        self.setSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadCategories()
        self.tableView.reloadData()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == "NotificationDetailSegue" {
            let notificationDetailTableViewController = segue.destination as! NotificationDetailTableViewController
            notificationDetailTableViewController.category = self.selectedCategory
        }
    }
    
    @IBAction func unwindToNotificationTableViewController(unwindSegue: UIStoryboardSegue) {
        guard let identifier = unwindSegue.identifier else {
            print("Cannot find unwind segue identifier")
            return
        }
        if identifier == "UnwindFromNotificationDetailTableViewController" {
            
        }
    }

}

// Search bar extension
extension NotificationTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
