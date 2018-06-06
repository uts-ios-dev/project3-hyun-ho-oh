//
//  FlashCardViewController.swift
//  Memorable
//
//  Created by Hyun Ho Oh on 5/6/18.
//  Copyright © 2018 University of Technology Sydney. All rights reserved.
//

import UIKit
import os.log

class FlashCardViewController: UIViewController {
    
    // MARK: Properties
    
    var category = Category(name: "")
    var memorables: [Memorable] = []
    var memorablesInCategory: [Memorable] = []
    
    var shuffleSetting = false
    var timeIntervalSetting = 1
    var repeatSetting = false
    
    // MARK: Outlets
    
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: Methods
    
    func loadMemorables() -> [Memorable] {
        if let savedMemorables = NSKeyedUnarchiver.unarchiveObject(withFile: Memorable.ArchiveURL.path) as? [Memorable] {
            return savedMemorables
        } else {
            os_log("Failed to laod memorables...", log: OSLog.default, type: .error)
            return []
        }
    }
    
    func setMemorablesInCategory() {
        self.memorablesInCategory = []
        for memorable in self.memorables {
            if memorable.category == self.category.name {
                self.memorablesInCategory.append(memorable)
            }
        }
    }
    
    func startFlashCard() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        self.view.addSubview(label)
        DispatchQueue.global(qos: .userInitiated).async {
            for memorableInCategory in self.memorablesInCategory {
                DispatchQueue.main.async {
                    let title = memorableInCategory.head
                    label.textColor = .black
                    label.text = title
                }
                sleep(UInt32(self.timeIntervalSetting))
                DispatchQueue.main.async {
                    let description = memorableInCategory.body
                    label.textColor = .gray
                    label.text = description
                }
                sleep(UInt32(self.timeIntervalSetting))
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func startButtonClicked(_ sender: Any) {
        self.startButton.removeFromSuperview()
        self.startFlashCard()
    }
    
    // MARK: View controller life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.category.name
        self.memorables = self.loadMemorables()
        self.setMemorablesInCategory()
    }
    
}
