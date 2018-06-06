//
//  QuizViewController.swift
//  Memorable
//
//  Created by Hyun Ho Oh on 5/6/18.
//  Copyright © 2018 University of Technology Sydney. All rights reserved.
//

import UIKit
import os.log

class QuizViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var category = Category(name: "")
    var memorables: [Memorable] = []
    var memorablesInCategory: [Memorable] = []
    
    var quizMemorables: [Memorable] = []
    
    var currentQuestionMemorable = Memorable(id: -1, head: "", body: "", category: "")
    var answers: [String] = []
    var currentQuizeIndex = 0
    
    var totalScore = 0
    var currentScore = 0
    var userAnswer = ""
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerPickerView: UIPickerView!
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if self.memorablesInCategory.count > 0 {
            self.userAnswer = self.answers[self.answerPickerView.selectedRow(inComponent: 0)]
        } else {
            return
        }
        if self.userAnswer == self.currentQuestionMemorable.body {
            self.currentScore += 1
        }
        if self.quizMemorables.count > 0 {
            if currentQuizeIndex < self.quizMemorables.count {
                self.currentQuestionMemorable = self.quizMemorables[self.currentQuizeIndex]
                self.currentQuizeIndex += 1
            } else {
                print("Current Score: \(self.currentScore)/\(self.totalScore)")
                self.alert(title: "Result", message: "\(self.currentScore)/\(self.totalScore)", dismissButtonText: "Quit")
            }
            self.questionLabel.text = self.currentQuestionMemorable.head
            self.setAnswers()
            self.answerPickerView.reloadAllComponents()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.answers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.answers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
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
    
    func shuffleMemorablesInCategory() {
        self.quizMemorables = self.memorablesInCategory
        self.quizMemorables.shuffle()
    }
    
    func setAnswers() {
        self.answers = []
        self.answers.append(self.currentQuestionMemorable.body)
        for memorable in self.memorablesInCategory {
            if self.answers.count >= 4 {
                break
            }
            if memorable.id != self.currentQuestionMemorable.id {
                self.answers.append(memorable.body)
            }
        }
        self.answers.shuffle()
    }
    
    func alert(title: String, message: String, dismissButtonText: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let dismissAction = UIAlertAction(title: dismissButtonText,style: UIAlertActionStyle.default) {
            (action) -> Void in
            self.performSegue(withIdentifier: "unwindFromQuizViewController", sender: self)
        }
        alertController.addAction(dismissAction)
        // alertController.addAction(UIAlertAction(title: dismissButtonText, style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        answerPickerView.dataSource = self
        answerPickerView.delegate = self
        self.navigationItem.title = self.category.name
        self.memorables = self.loadMemorables()
        self.setMemorablesInCategory()
        self.shuffleMemorablesInCategory()
        if self.quizMemorables.count > 0 {
            if currentQuizeIndex < self.quizMemorables.count {
                self.currentQuestionMemorable = self.quizMemorables[self.currentQuizeIndex]
                self.currentQuizeIndex += 1
            } else {
                self.currentQuizeIndex = 0
                print("Current Score: \(self.currentScore)/\(self.totalScore)")
                self.currentScore = 0
            }
            self.questionLabel.text = self.currentQuestionMemorable.head
            self.setAnswers()
        }
        self.totalScore = self.memorablesInCategory.count
    }

}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
