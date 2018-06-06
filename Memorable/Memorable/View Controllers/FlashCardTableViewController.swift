//
//  FlashCardTableViewController.swift
//  Memorable
//
//  Created by Hyun Ho Oh on 5/6/18.
//  Copyright © 2018 University of Technology Sydney. All rights reserved.
//

import UIKit
import os.log

class FlashCardTableViewController: UITableViewController {
    
    var categories: [Category] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCategories = [Category]()
    
    var selectedCategory = Category(name: "")
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCategories()
        self.setSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadCategories()
        self.tableView.reloadData()
    }
    
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
        self.performSegue(withIdentifier: "FlashMemorable", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == "FlashMemorable" {
            let flashCardViewController = segue.destination as! FlashCardViewController
            flashCardViewController.category = self.selectedCategory
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
    
    func loadCategories() {
        if let savedCategories = NSKeyedUnarchiver.unarchiveObject(withFile: Category.ArchiveURL.path) as? [Category] {
            self.categories = savedCategories
        } else {
            os_log("Failed to laod categories...", log: OSLog.default, type: .error)
        }
    }

}

extension FlashCardTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
