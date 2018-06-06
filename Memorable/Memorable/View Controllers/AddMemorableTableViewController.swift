//
//  AddMemorableTableViewController.swift
//  Memorable
//
//  Created by Hyun Ho Oh on 5/6/18.
//  Copyright © 2018 University of Technology Sydney. All rights reserved.
//

import UIKit
import os.log

class AddMemorableTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var categories: [Category] = []
    
    private func loadCategories() {
        if let savedCategories = NSKeyedUnarchiver.unarchiveObject(withFile: Category.ArchiveURL.path) as? [Category] {
            self.categories = savedCategories
        } else {
            os_log("Failed to laod categories...", log: OSLog.default, type: .error)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.categories[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    

    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.loadCategories()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
