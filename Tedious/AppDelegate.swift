//
//  AppDelegate.swift
//  Tedious
//
//  Created by Nguyen Chi Dung on 4/11/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GooglePlaces
import GoogleMaps
import SVProgressHUD
import Stripe
import AppRating

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey(K.API.Google.Key.Services)
        GMSPlacesClient.provideAPIKey(K.API.Google.Key.Places)
        FirebaseApp.configure()
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        adjustNavigationBar()
        PushNotificationManager.shared.register()
        configureAppRatingIfNeed()
        return true
    }

    func adjustNavigationBar() {
        let attrs = [
            NSAttributedStringKey.font: UIFont(name: K.Font.Regular, size: 24)!,
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
        UINavigationBar.appearance().setBackgroundImage(UIImage.from(color: UIColor(hex: 0x2192D9)), for: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage.from(color: UIColor(hex: 0x2192D9))
        UINavigationBar.appearance().tintColor = UIColor.white
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white],
                                                            for: .normal)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Tedious")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Configure App rating
    
    private func configureAppRatingIfNeed() {
        if K.App.Target == .Customer {
            AppRating.appID(K.App.CustomerAppStoreId);
            AppRating.debugEnabled(true);
            
            // reset the counters (for testing only);
            AppRating.resetAllCounters();
            
            // set some of the settings (see the github readme for more information about that)
            AppRating.daysUntilPrompt(0);
            AppRating.secondsBeforePromptIsShown(3);
            AppRating.significantEventsUntilPrompt(0);
        }
    }

}

