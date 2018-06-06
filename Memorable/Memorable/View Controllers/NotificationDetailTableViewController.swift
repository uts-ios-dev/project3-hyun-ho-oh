//
//  NotificationDetailTableViewController.swift
//  Memorable
//
//  Created by Hyun Ho Oh on 6/6/18.
//  Copyright © 2018 University of Technology Sydney. All rights reserved.
//

import UIKit
import UserNotifications
import os.log

class NotificationDetailTableViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    // MARK: PROPERTY
    
    var category = Category(name: "")
    var memorables: [Memorable] = []
    var memorablesInCategory: [Memorable] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredMemorables = [Memorable]()
    
    var selectedMemorable = Memorable(id: -1, head: "", body: "", category: "")
    
    // MARK: METHOD
    
    func loadMemorables() {
        if let savedMemorables = NSKeyedUnarchiver.unarchiveObject(withFile: Memorable.ArchiveURL.path) as? [Memorable] {
            self.memorables = savedMemorables
        } else {
            os_log("Failed to laod memorables...", log: OSLog.default, type: .error)
        }
    }
    
    func setMemorableInCategory() {
        self.memorablesInCategory = []
        for memorable in self.memorables {
            if memorable.category == self.category.name {
                self.memorablesInCategory.append(memorable)
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredMemorables = memorablesInCategory.filter({( memorable : Memorable) -> Bool in
            return memorable.head.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
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
    
    private func setLabelForEmptyTable() {
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height)))
        label.text = "No memorable for '\(self.category.name)'.\n Go to category tab to add."
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .gray
        self.tableView.backgroundView = label
        self.tableView.separatorStyle = .none
    }

    // MARK: LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.category.name
        self.loadMemorables()
        self.setMemorableInCategory()
        self.setSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadMemorables()
        self.setMemorableInCategory()
        self.tableView.reloadData()
    }
    
    // MARK: DATA SOURCE
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.memorablesInCategory.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        } else {
            self.setLabelForEmptyTable()
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredMemorables.count
        }
        if section == 0 {
            return self.memorablesInCategory.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Memorables", for: indexPath)
        let memorable: Memorable
        if isFiltering() {
            memorable = self.filteredMemorables[indexPath.row]
        } else {
            memorable = self.memorablesInCategory[indexPath.row]
        }
        cell.showsReorderControl = true
        cell.textLabel?.text = memorable.head
        cell.detailTextLabel?.text = memorable.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFiltering() {
            self.selectedMemorable = self.filteredMemorables[indexPath.row]
        } else {
            self.selectedMemorable = self.memorablesInCategory[indexPath.row]
        }
        print("\(self.selectedMemorable.head) (ID: \(self.selectedMemorable.id))")
        self.performSegue(withIdentifier: "NotificationSettingSegue", sender: nil)
    }
    
    // MARK: NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == "NotificationSettingSegue" {
            let notificationSettingTableViewController = segue.destination as! NotificationSettingTableViewController
            notificationSettingTableViewController.memorable = self.selectedMemorable
        }
    }
    
    @IBAction func unwindToNotificationDetailTableViewController(unwindSegue: UIStoryboardSegue) {
        guard let identifier = unwindSegue.identifier else {
            print("Cannot find unwind segue identifier")
            return
        }
        if identifier == "UnwindFromNotificationSettingTableViewController" {
            
        }
    }

}

extension NotificationDetailTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
