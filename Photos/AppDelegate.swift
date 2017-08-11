//
//  AppDelegate.swift
//  Photos
//
//  Created by Vladislav Shilov on 05.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let barTintColor = UIColor(red: 93/255, green: 208/255, blue: 192/255,
                                   alpha: 0.75)
        
        if let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView{
            statusBar.backgroundColor = barTintColor
        }
        
        
        
        GMSServices.provideAPIKey("AIzaSyBcn9fVPb8QCZ3s9TNNvnoaAx0XGV1DwZc")
               print(applicationDocumentsDirectory.path)
        
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            preloadData()
            defaults.set(true, forKey: "isPreloaded")
        }
        
        return true
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
        let container = NSPersistentContainer(name: "Photos")
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
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.appcoda.CoreDataDemo" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        return managedObjectContext!
    }()
    

    // MARK: - CSV Parser Methods
    
    func parseCSV (_ contentsOfURL: URL, encoding: String.Encoding) -> [(lat: String, lng: String, disc: String, name: String)]? {
        
        // Load the CSV file and parse it
        let delimiter = ","
        var items:[(lat: String, lng: String, disc: String, name: String)]?
        
        do {
            let content = try String(contentsOf: contentsOfURL, encoding: encoding)
            print(content)
            items = []
            let lines:[String] = content.components(separatedBy: CharacterSet.newlines) as [String]
            
            for line in lines {
                var values:[String] = []
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    if line.range(of: "\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:Scanner = Scanner(string: textToScan)
                        while textScanner.string != "" {
                            
                            if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpTo("\"", into: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpTo(delimiter, into: &value)
                            }
                            
                            // Store the value into the values array
                            values.append(value! as String)
                            
                            // Retrieve the unscanned remainder of the string
                            if textScanner.scanLocation < textScanner.string.characters.count {
                                textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = Scanner(string: textToScan)
                        }
                        
                        // For a line without double quotes, we can simply separate the string
                        // by using the delimiter (e.g. comma)
                    } else  {
                        values = line.components(separatedBy: delimiter)
                    }
                    
                    // Put the values into the tuple and add it to the items array
                    let item = (lat: values[0], lng: values[1], disc: values[2], name: values[3])
                    items?.append(item)
                }
            }
            
        } catch {
            print(error)
        }
        
        return items
    }
    
    func preloadData () {
        
        // Load the data file. For any reasons it can't be loaded, we just return
        //        guard let remoteURL = URL(string: "https://googledrive.com/host/0ByZhaKOAvtNGTHhXUUpGS3VqZnM/menudata.csv") else {
        //            return
        //        }
        
        //Load form CSV
        guard let contentsOfURL = Bundle.main.url(forResource: "mapData", withExtension: "csv") else {
            return
        }
        
        // Remove all the menu items before preloading
        removeData()
        
        if let items = parseCSV(contentsOfURL, encoding: String.Encoding.utf8) {
            // Preload the menu items
            for item in items {
                let mapItem = NSEntityDescription.insertNewObject(forEntityName: "MapItem", into: managedObjectContext) as! MapItem
                
                let lng: Float = Float(item.lng)!
                let lat: Float = Float(item.lat)!
                
                mapItem.latitude = lat
                mapItem.longitude = lng
                mapItem.discription = item.disc
                mapItem.name = item.name
                
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
            
        }
    }
    
    func removeData () {
        // Remove the existing items
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MapItem")
        
        do {
            let menuItems = try managedObjectContext.fetch(fetchRequest) as! [MapItem]
            for menuItem in menuItems {
                managedObjectContext.delete(menuItem)
            }
        } catch {
            print(error)
        }
        
    }


}

