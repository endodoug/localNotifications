//
//  ViewController.swift
//  HuliPizzaNotification
//
//  Created by Steven Lipton on 1/10/17.
//  Copyright © 2017 Steven Lipton. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
  
  // property to store access status
  var isGrantedNotificationAccess = true
  
  // function to contain the content in my notification
  func createPizzaContent() -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "A Timed Pizza Step"
    content.body = "Making Pizza"
    content.userInfo = ["step": 0]
    
    return content
  }
  
  // Notification Request function
  func addNotification(trigger: UNNotificationTrigger?, content: UNMutableNotificationContent, identifier: String) {
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { (error) in
      if error != nil {
        print("error adding notification: \(String(describing: error?.localizedDescription))")
      }
    }
  }
  
  @IBAction func schedulePizza(_ sender: UIButton) {
    if isGrantedNotificationAccess {
      let content = UNMutableNotificationContent()
      content.title = "A Scheduled Pizza"
      content.body = "Time to make a Pizza!!!"
      
      let unitFlags: Set<Calendar.Component> = [.minute, .hour, .second]
      var date = Calendar.current.dateComponents(unitFlags, from: Date())
      date.second = date.second! + 15
      
      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
      
      addNotification(trigger: trigger, content: content, identifier: "message.schedule")
    }
  }
  @IBAction func makePizza(_ sender: UIButton) {
    if isGrantedNotificationAccess {
      let content = createPizzaContent()
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
      addNotification(trigger: trigger, content: content, identifier: "message.pizza")
    }
  }
  
  @IBAction func nextPizzaStep(_ sender: UIButton) {
  }
  
  @IBAction func viewPendingPizzas(_ sender: UIButton) {
  }
  
  @IBAction func viewDeliveredPizzas(_ sender: UIButton) {
  }
  
  @IBAction func removeNotification(_ sender: UIButton) {
  }
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // request authorization method could also be placed in AppDelegate
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
      self.isGrantedNotificationAccess = granted
      if !granted {
        // add alert to persuade user
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

