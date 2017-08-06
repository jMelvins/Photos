//
//  MenuViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 06.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit

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
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()        
    }

}
