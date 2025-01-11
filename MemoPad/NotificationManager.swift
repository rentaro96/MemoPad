//
//  NotificationManager.swift
//  MemoPad
//
//  Created by 鈴木廉太郎 on 2025/01/11.
//

import Foundation
import CoreLocation
import NotificationCenter

class NotificationManager {
    
    static func setTimeIntervalNotification(title: String, timeInterval: TimeInterval) {
        UserNotifications.UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert,.sound]){ granted, error in
            if granted {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = title
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                
                
            }
        
        }
    }
}

