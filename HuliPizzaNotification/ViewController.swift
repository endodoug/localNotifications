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
  var isGrantedNotificationAccess = false
  
  var pizzaNumber = 0
  let pizzaSteps = ["Make Pizza", "Roll Dough", "Add Sauce", "Add Cheese", "Add Ingredients", "Bake", "Done"]
  
  func updatePizzaStep(request: UNNotificationRequest) {
    if request.identifier.hasPrefix("message.pizza") {
      var stepNumber = request.content.userInfo["step"] as! Int
      stepNumber = (stepNumber + 1) % pizzaSteps.count
      let updatedContent = createPizzaContent()
      updatedContent.body = pizzaSteps[stepNumber]
      updatedContent.userInfo[stepNumber] = stepNumber
      updatedContent.subtitle = request.content.subtitle
      addNotification(trigger: request.trigger, content: updatedContent, identifier: request.identifier)
    }
  }
  
  // function to contain the content in my notification
  func createPizzaContent() -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "A Timed Pizza Step"
    content.body = "Making Pizza"
    content.userInfo = ["step": 0]
    content.categoryIdentifier = "pizza.step.category"
    
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
      content.categoryIdentifier = "snooze.category"
      
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
      pizzaNumber += 1
      content.subtitle = "Pizza \(pizzaNumber)"
      
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
      addNotification(trigger: trigger, content: content, identifier: "message.pizza.\(pizzaNumber)")
    }
  }
  
  @IBAction func nextPizzaStep(_ sender: UIButton) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { (requests)  in
      if let request = requests.first {
        self.updatePizzaStep(request: request)
        if request.identifier.hasPrefix("message.pizza") {
          self.updatePizzaStep(request: request)
        } else {
          let content = request.content.mutableCopy() as! UNMutableNotificationContent
          self.addNotification(trigger: request.trigger!, content: content, identifier: request.identifier)
        }
      }
    }
  }
  
  @IBAction func viewPendingPizzas(_ sender: UIButton) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { (requestList) in
      print("\(Date()) --> \(requestList.count) requests pending")
      for request in requestList {
        print("\(request.identifier) body: \(request.content.body)")
      }
    }
  }
  
  @IBAction func viewDeliveredPizzas(_ sender: UIButton) {
    UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
      print("\(Date()) ---- \(notifications.count) delivered")
      for notification in notifications {
        print("\(notification.request.identifier)  \(notification.request.content.body)")
      }
    }
  }
  
  @IBAction func removeNotification(_ sender: UIButton) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
      if let request = requests.first {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
      }
    }
  }
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UNUserNotificationCenter.current().delegate = self
    
    // request authorization method could also be placed in AppDelegate
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
      self.isGrantedNotificationAccess = granted
      if !granted {
        // add alert to persuade user
      }
    }
  }
}

func setBadgeIndicator(badgeCount:Int)
{
  let application = UIApplication.shared
  if #available(iOS 10.0, *) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in }
  }
  else{
    application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
  }
  application.registerForRemoteNotifications()
  application.applicationIconBadgeNumber = badgeCount
}

// MARK: - Delegates

extension ViewController: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let action = response.actionIdentifier
    let request = response.notification.request
    if action == "next.step.action" {
      updatePizzaStep(request: request)
    }
    if action == "stop.action" {
      UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
    }
    if action == "snooze.action" {
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
      let newRequest = UNNotificationRequest(identifier: request.identifier, content: request.content, trigger: trigger)
      UNUserNotificationCenter.current().add(newRequest, withCompletionHandler: { (error) in
        if error != nil {
          print("\(String(describing: error?.localizedDescription))")
        }
      })
    }
    completionHandler()
  }

}

