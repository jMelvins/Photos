//
//  SignUpViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 05.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, NetworkingStuffDelegate{

    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatedPasswordTextField: UITextField!
    
    var networkingStuff: NetworkingStuff!
    let signURL = "http://213.184.248.43:9099/api/account/signup"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkingStuff = NetworkingStuff(delegate: self)

        // Do any additional setup after loading the view.
    }

    func didGetUser(_ user: User) {
        statusLabel.text = "You are succesfully signed in!\nYour token: \(user.token!)"
    }
    
    func didGetError(errorNumber: Int, errorDiscription: String) {
        statusLabel.text = "Ooops it's an error!\n\(errorNumber) : \(errorDiscription)"
    }

    @IBAction func signupButton(_ sender: UIButton) {
        
        guard isDataCorrect() else {
            return
        }
        
        networkingStuff.authorization(url: signURL, userName: loginTextField.text!, userPassword: passwordTextField.text!)
        self.dismiss(animated: true, completion: nil)
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
        if passwordTextField.text != repeatedPasswordTextField.text {
            statusLabel.text = "Password and Repeated Password must be the same!"
            return false
        }
        
        statusLabel.text = "SignUp"
        return true
    }

}
