//
//  NotificationSettingTableViewController.swift
//  Memorable
//
//  Created by Hyun Ho Oh on 6/6/18.
//  Copyright © 2018 University of Technology Sydney. All rights reserved.
//

import UIKit
import UserNotifications
import os.log

class NotificationSettingTableViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    // MARK: PROPERTY
    
    var memorable = Memorable(id: -1, head: "", body: "", category: "")
    var turnOnOffValue = false
    var notificationSettings: [NotificationSetting] = []
    
    // MARK: OUTLET
    
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var repeatIntervalSlider: UISlider!
    @IBOutlet weak var turnOnOffSwitch: UISwitch!
    
    // MARK: ACTION
    
    @IBAction func repeatIntervalSliderValueChanged(_ sender: Any) {
        self.repeatLabel.text = String(Int(self.repeatIntervalSlider.value)) + " seconds"
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let notificationSetting = NotificationSetting(memorable: self.memorable, repeatInterval: Int(self.repeatIntervalSlider.value), turnOnOff: self.turnOnOffValue)
        self.notificationSettings.append(notificationSetting)
        self.saveNotificationSettings()
        if self.turnOnOffValue {
            self.requestLocalNotification(timeInterval: Int(self.repeatIntervalSlider.value))
            self.alertWithSegue(title: self.memorable.head, message: "Notification on", dismissButtonText: "Go back", segueIdentifier: "UnwindFromNotificationSettingTableViewController")
        } else {
            self.removeNotifications()
            self.alertWithSegue(title: self.memorable.head, message: "Notification off", dismissButtonText: "Go back", segueIdentifier: "UnwindFromNotificationSettingTableViewController")
        }
    }
    
    @IBAction func turnOnOffSwitchValueChanged(_ sender: Any) {
        if self.turnOnOffValue {
            self.turnOnOffValue = false
        } else {
            self.turnOnOffValue = true
        }
    }
    
    // MARK: METHOD
    
    func requestLocalNotification(timeInterval: Int) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            
            print("Permission granted: \(granted)")
            guard granted else { return }
            
            UNUserNotificationCenter.current().getNotificationSettings {
                (settings) in
                
                print("Notification settings: \(settings)")
                print("Authorization Status: \(settings.authorizationStatus.rawValue)")
                guard settings.authorizationStatus == .authorized else {
                    print("Not authorized")
                    return
                }
                
                // Creating the notification content
                let content = UNMutableNotificationContent()
                
                // Adding title, subtitle, body and badge
                content.title = self.memorable.head
                // content.subtitle = "Hello, world!"
                content.body = self.memorable.body
                content.badge = 0
                
                
                // Getting the notification trigger
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: true)
                
                // Getting the notification request
                let request = UNNotificationRequest(identifier: String(self.memorable.id), content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().delegate = self
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
    
    func removeNotifications() {
        // UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        // UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        var identifier: [String] = []
        identifier.append(String(self.memorable.id))
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifier)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifier)
    }
    
    func alertWithSegue(title: String, message: String, dismissButtonText: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let dismissAction = UIAlertAction(title: dismissButtonText,style: UIAlertActionStyle.default) {
            (action) -> Void in
            self.performSegue(withIdentifier: segueIdentifier, sender: self)
        }
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
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
    
    // MARK: LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.memorable.head
        self.loadNotificationSettings()
        for notificationSetting in self.notificationSettings {
            let memorable = notificationSetting.memorable
            let repeatInterval = notificationSetting.repeatInterval
            let turnOnOff = notificationSetting.turnOnOff
            if self.memorable.id == memorable.id {
                self.repeatIntervalSlider.setValue(Float(repeatInterval), animated: false)
                self.repeatLabel.text = String(Int(self.repeatIntervalSlider.value)) + " seconds"
                self.turnOnOffSwitch.setOn(turnOnOff, animated: false)
                self.turnOnOffValue = turnOnOff
            }
        }
    }

}
