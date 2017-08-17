//
//  AuthorizationViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 06.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import QuartzCore

class AuthorizationViewController: UIViewController, CAAnimationDelegate, NetworkingStuffDelegate{
    
    //MARK: Outlets
    @IBOutlet weak var segmentedControl: TabySegmentedControl!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatedPasswordLabel: UILabel!
    @IBOutlet weak var repeatedPasswordTextField: UITextField!
    @IBOutlet weak var authButton: UIButton!
    
    //MARK: Var
    //Позиции кнопки для CoreAnimation
    var defaultPosition: CGPoint?
    var newPos: CGPoint?
    
    var networkingStuff: NetworkingStuff!
    let signinURL = "http://213.184.248.43:9099/api/account/signin"
    let signupURL = "http://213.184.248.43:9099/api/account/signup"
    var user: User?

    //MARK: System
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthorizationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        networkingStuff = NetworkingStuff(delegate: self)
        
        //настройка сегмент контроллера
        segmentedControl.initUI()
        
        //Высчитываем позицию кнопки для SignIn и SignUp
        defaultPosition = authButton.frame.origin
        newPos = CGPoint(x: (defaultPosition?.x)! , y: (defaultPosition?.y)! + 70)
        
        repeatedPasswordTextField.isHidden = true
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }


    //MARK: Authorization functions
    
    func signIn(){
        
        if (loginTextField.text?.characters.count)! <= 3 {
            displayMyAlertMessage(title: "Your attention!", message: "Login size must be between 4 and 32", called: self)
            return 
        }
        if (passwordTextField.text?.characters.count)! <= 7 {
            displayMyAlertMessage(title: "Your attention!", message: "Password size must be between 8 and 500", called: self)
            return
        }
        statusLabel.text = "SignIn"
        
        networkingStuff.authorization(url: signinURL, userName: loginTextField.text!, userPassword: passwordTextField.text!)
    }
    
    func signUp(){
        
        if (loginTextField.text?.characters.count)! <= 3 {
            displayMyAlertMessage(title: "Your attention!", message: "Login size must be between 4 and 32", called: self)
            return
        }
        if (passwordTextField.text?.characters.count)! <= 7 {
            displayMyAlertMessage(title: "Your attention!", message: "Password size must be between 8 and 500", called: self)
            return
        }
        if passwordTextField.text != repeatedPasswordTextField.text {
            displayMyAlertMessage(title: "Your attention!", message: "Password and Repeated Password must be the same!",called: self)
            return
        }
        
        statusLabel.text = "SignUp"
        
        networkingStuff.authorization(url: signupURL, userName: loginTextField.text!, userPassword: passwordTextField.text!)
    }
    
    //MARK: Delegate
    
    func didGetUser(_ user: User) {
        
        let userLogin = user.login
        let userId = user.userId
        let userToken = user.token
        
        //Store data
        UserDefaults.standard.set(userLogin, forKey: "userLogin")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(userToken, forKey: "userToken")
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()
        
        dismiss(animated: true, completion: nil)
    }
    
    func didGetImageData(imageData: [ImageStruct]) {
        for item in imageData {
            print(item.id)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func didGetError(errorNumber: Int, errorDiscription: String) {
        displayMyAlertMessage(title: "Ooops", message: "It's an error \(errorNumber) : \(errorDiscription)", called: self)
    }
    
    //MARK: IBActions
    
    
    @IBAction func authBtnAction(_ sender: UIButton) {
        
        if Reachability.isConnectedToNetwork() != true {
            displayMyAlertMessage(title: "Networking issue.", message: "You cannot auth without the internet connection.", called: self)
            return
        }
        
        if segmentedControl.selectedSegmentIndex == 0{
            signIn()
        }else {
            signUp()
        }
    }
    
    @IBAction func segmentControll(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            animation(oldValue: newPos!, newValue: defaultPosition!, textFieldOpacity: 1, tfoNew: 0)
            authButton.frame.origin = defaultPosition!
            statusLabel.text = "SignIn"
            //repeatedPasswordTextField.isHidden = true
        }else{
            animation(oldValue: defaultPosition!, newValue: newPos!, textFieldOpacity: 0, tfoNew: 1)
            //чтобы кнопка была активной меняем ее положение
            authButton.frame.origin = newPos!
            statusLabel.text = "SignUp"
            repeatedPasswordTextField.isHidden = false
        }
        
    }
    
    //MARK: Animation
    
    func animation(oldValue: CGPoint, newValue: CGPoint, textFieldOpacity: Int, tfoNew: Int){
        
        var oldColor: UIColor?
        var newColor: UIColor?
        
        if tfoNew == 1{
            oldColor = UIColor(red: 93/255, green: 208/255, blue: 192/255, alpha: 1)
            newColor = UIColor(red: 255/255, green: 106/255, blue: 0/255, alpha: 1)
        }else {
            oldColor = UIColor(red: 255/255, green: 106/255, blue: 0/255, alpha: 1)
            newColor = UIColor(red: 93/255, green: 208/255, blue: 192/255, alpha: 1)
        }
        
        let panelMover = CABasicAnimation(keyPath: "position")
        
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        let bound = authButton.bounds.size
        let fromValue = CGPoint(x: oldValue.x + bound.width/2, y: oldValue.y + bound.height/2)
        let toValue = CGPoint(x: newValue.x + bound.width/2, y: newValue.y + bound.height/2)
        panelMover.fromValue = NSValue(cgPoint: fromValue)
        panelMover.toValue = NSValue(cgPoint: toValue)
        panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        
        authButton.layer.add(panelMover, forKey: "panelMover")
        
        let btnColor = CABasicAnimation(keyPath: "backgroundColor")
        
        btnColor.isRemovedOnCompletion = false
        btnColor.fillMode = kCAFillModeForwards
        btnColor.fromValue = oldColor?.cgColor
        btnColor.toValue = newColor?.cgColor
        btnColor.duration = 0.4
        btnColor.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        btnColor.delegate = self
        
        authButton.layer.add(btnColor, forKey: "btnColor")
        
        
        let textField = CABasicAnimation(keyPath: "opacity")
        
        textField.isRemovedOnCompletion = false
        textField.fillMode = kCAFillModeForwards
        textField.fromValue = textFieldOpacity
        textField.toValue = tfoNew
        textField.duration = 0.6
        textField.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        textField.delegate = self
        
        repeatedPasswordTextField.layer.add(textField, forKey: "textField")
        
        let passLabel = CABasicAnimation(keyPath: "opacity")
        
        passLabel.isRemovedOnCompletion = false
        passLabel.fillMode = kCAFillModeForwards
        passLabel.fromValue = textFieldOpacity
        passLabel.toValue = tfoNew
        passLabel.duration = 0.6
        passLabel.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        passLabel.delegate = self
        
        repeatedPasswordLabel.layer.add(textField, forKey: "passLabel")
        
    }

}
