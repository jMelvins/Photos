//
//  PhotosCollectionViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 06.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import CoreLocation

private let reuseIdentifier = "cell"

class PhotosCollectionViewController: UICollectionViewController, ImageGetterDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    var images: [Data] = []
    
    var mainUser = User()
    var imageStruct = [ImageStruct]()
    var imageGetter: ImageGetter!
    let imageURL = "http://213.184.248.43:9099/api/image"
    
    var image: UIImage?
    let locationManager = CLLocationManager()
    var location: CLLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageGetter = ImageGetter(delegate: self)

        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        
        if !isUserLoggedIn{
            self.performSegue(withIdentifier: "Auth", sender: self)
        }else {
            mainUser.login = UserDefaults.standard.value(forKey: "userLogin") as? String
            mainUser.userId = UserDefaults.standard.value(forKey: "userId") as? Int
            mainUser.token = UserDefaults.standard.value(forKey: "userToken") as? String
            
            //Исправить на адекватную проверку
            if images.isEmpty{
                 imageGetter.getImageData(url: imageURL, page: 0, token: mainUser.token!)
            }
        }
    }
    
    // MARK: ImageGetterDelegate
    
    func didGetImage(image: Data) {
        images.append(image)
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func didGetImageData(imageData: [ImageStruct]) {
        imageStruct = imageData
        
        for imageItem in imageStruct{
            imageGetter.downloadImage(imageURL: imageItem.url)
        }
    }
    
    func didGetError(errorNumber: Int, errorDiscription: String) {
        displayMyAlertMessage(title: "Ooops", message: "It's an error \(errorNumber) : \(errorDiscription)", called: self)
    }
    
    // MARK: IBActions
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        guard CLLocationManager.locationServicesEnabled() else {
            displayMyAlertMessage(
                title: "Please turn on location services",
                message: "This app needs location services in order to report the weather " +
                    "for your current location.\n" +
                "Go to Settings → Privacy → Location Services and turn location services on.",
                called: self)
            return
        }
        
        let locationAuthStatus = CLLocationManager.authorizationStatus()
        if locationAuthStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if locationAuthStatus == .denied || locationAuthStatus == .restricted {
            displayMyAlertMessage(title: "Location auth status", message: "Please enable location services for this app in Settings.", called: self)
            return
        }
        
        //Если все ОК, то начинаем искать наши координаты
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
        
        pickPhoto()
    }
    
    // MARK: CLLocationManager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last
        
        print("Loction: \(newLocation?.coordinate)")
        location = newLocation
        
        print("lat :\((location?.coordinate.latitude)!)")
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error: \(error)")
        
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotosCollectionViewCell
    
        cell.imageView.image = UIImage(data: images[indexPath.row])
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(mainUser.login)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailImageVC" {
            if let indexPath = collectionView?.indexPath(for: sender as! PhotosCollectionViewCell){
                let newVC = segue.destination as! DetailPhotoViewController
                newVC.imageData = images[indexPath.row]
            }
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}


extension PhotosCollectionViewController:
UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        
        //изменяем на цвет соответтствующий цвету тайнта в текущем ВК
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()        //let imagePicker = UIImagePickerController()
        
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil,
                                                preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,
                                         handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { _ in self.takePhotoWithCamera() })
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library",
                                                    style: .default,
                                                    handler: { _ in self.choosePhotoFromLibrary() })
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        //Если брать картинку без редактирвоания
        //image = info[UIImagePickerControllerOriginalImage] as? UIImage
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        //т.к. image - опцоиональный тип
        if let theImage = image {
            
            let date = (location?.timestamp)!.timeIntervalSince1970
            imageGetter.uploadImage(imageURL: imageURL, token: mainUser.token!, date: Int(date), lat: Float((location?.coordinate.latitude)!), lng: Float((location?.coordinate.longitude)!), imageData: UIImagePNGRepresentation(theImage)!)
            
            images.append(UIImagePNGRepresentation(theImage)!)
            self.collectionView?.reloadData()
        }
        
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
