//
//  MenuViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 06.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class MenuViewController: UITableViewController {

    @IBOutlet weak var menuLabel: UILabel!
    
    var userName: String? {
        didSet{
            update()
        }
    }
    
    func update(){
        menuLabel.text = userName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        
        if isUserLoggedIn{
            userName = UserDefaults.standard.value(forKey: "userLogin") as? String
        }
    }

    @IBAction func logoutBtn(_ sender: UIButton) {
        //TODO: - Stop Alamofire download
        //TODO: - Clear CoreData - GET
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        
        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false
        
        let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        
        do {
            let items = try managedObjectContext?.fetch(fetchRequest) as! [NSManagedObject]
            
            for item in items {
                managedObjectContext?.delete(item)
            }
            
            // Save Changes
            try managedObjectContext?.save()
            
        } catch {
            print(error)
        }
        
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.set(false, forKey: "isImagesDownloaded")
        UserDefaults.standard.synchronize()        
    }

}
