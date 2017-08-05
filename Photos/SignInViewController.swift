//
//  SignInViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 05.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, NetworkingStuffDelegate{

    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    
    var networkingStuff: NetworkingStuff!
    let signURL = "http://213.184.248.43:9099/api/account/signin"
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkingStuff = NetworkingStuff(delegate: self)
    }
    
    func didGetUser(_ user: User) {
        statusLabel.text = "You are succesfully signed in!\nYour token: \(user.token!)"
    }
    
    func didGetError(errorNumber: Int, errorDiscription: String) {
        statusLabel.text = "Ooops it's an error!\n\(errorNumber) : \(errorDiscription)"
    }
    
    @IBAction func signinButton(_ sender: UIButton) {
        guard isDataCorrect() else {
            return
        }
        networkingStuff.authorization(url: signURL, userName: loginTextField.text!, userPassword: passwordTextField.text!)
    }
    
    func isDataCorrect() -> Bool{
        if (loginTextField.text?.characters.count)! <= 3 {
            statusLabel.text = "Login size must be between 4 and 32"
            return false
        }
        if (passwordTextField.text?.characters.count)! <= 7 {
            statusLabel.text = "Password size must be between 8 and 500"
            return false
        }
        
        return true
    }
    
}
