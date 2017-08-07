//
//  Functions.swift
//  Photos
//
//  Created by Vladislav Shilov on 07.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import Foundation


func displayMyAlertMessage(title: String, message: String, called: UIViewController) {
    
    let myAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    
    myAlert.addAction(okAction)
    
    called.present(myAlert, animated: true, completion: nil)
    
}
