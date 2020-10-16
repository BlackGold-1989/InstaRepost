//
//  AppDelegate.swift
//  YPImagePickTest
//
//  Created by nforma on 9/14/18.
//  Copyright © 2018 nforma. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import FBSDKCoreKit
import SVProgressHUD
import YandexMobileMetrica

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let productIdentifier = "com.sg.interclick.repostforinstagramstories.monthly"
    let secretKey = "0cfe90c9cd0b466294378380c3740c90"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        YMMYandexMetrica.activate(withApiKey: "d7adbda4-f6e3-459c-adb5-412b72d59347")
        
        // trackerParametersDictionary
        var trackerParametersDictionary: [AnyHashable: Any] = [:]
        trackerParametersDictionary[kKVAParamAppGUIDStringKey] = "korepost-for-instagram-story-k1j5dnydy"
        trackerParametersDictionary[kKVAParamLogLevelEnumKey] = kKVALogLevelEnumInfo
        
        // KochavaTracker.shared
        KochavaTracker.shared.configure(withParametersDictionary: trackerParametersDictionary, delegate: self as? KochavaTrackerDelegate)
        
        // Override point for customization after application launch.
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("purchased: \(purchase)")
                }
            }
        }
        SVProgressHUD.setDefaultStyle(.dark)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        self.setUpLocalNotification(hour: 13, minute: 0)
        
        self.verifyReceipt()
        
        return true
    }
    
    func verifyReceipt() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: secretKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            SVProgressHUD.dismiss()
            if case .success(let receipt) = result {
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: self.productIdentifier,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased( _, _):
                    UserDefaults.standard.set(true, forKey: "Purchased")
                case .expired( _, _):
                    UserDefaults.standard.set(false, forKey: "Purchased")
                case .notPurchased:
                    UserDefaults.standard.set(false, forKey: "Purchased")
                }
                
            } else {
                // receipt verification error
                UserDefaults.standard.set(false, forKey: "Purchased")
            }
        }
    }
    
    func setUpLocalNotification(hour: Int, minute: Int) {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        
        // have to use NSCalendar for the components
        let calendar = NSCalendar(identifier: .gregorian)!;
        
        var dateFire = Date()
        
        // if today's date is passed, use tomorrow
        var fireComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from:dateFire)
        
        if (fireComponents.hour! > hour
            || (fireComponents.hour == hour && fireComponents.minute! >= minute) ) {
            
            dateFire = dateFire.addingTimeInterval(86400)  // Use tomorrow's date
            fireComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from:dateFire);
        }
        
        // set up the time
        fireComponents.hour = hour
        fireComponents.minute = minute
        
        // schedule local notification
        dateFire = calendar.date(from: fireComponents)!
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = dateFire
        localNotification.alertBody = NSLocalizedString("Get 100s Of Insta Followers. Make a New Story",comment:"")
        localNotification.repeatInterval = NSCalendar.Unit.day
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        UIApplication.shared.scheduleLocalNotification(localNotification);
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return handled
    }
    
}

