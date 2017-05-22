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
  
  @IBAction func schedulePizza(_ sender: UIButton) {
    if isGrantedNotificationAccess {
      let content = UNMutableNotificationContent()
      content.title = "A Scheduled Pizza"
      content.body = "Time to make a Pizza!!!"
    }
  }
  @IBAction func makePizza(_ sender: UIButton) {
    if isGrantedNotificationAccess {
      let content = createPizzaContent()
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

