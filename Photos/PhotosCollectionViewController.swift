//
//  PhotosCollectionViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 06.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"

class PhotosCollectionViewController: UICollectionViewController, ImageGetterDelegate {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    var images: [Data] = []
    
    var mainUser = User()
    var imageStruct = [ImageStruct]()
    var imageGetter: ImageGetter!
    let imageURL = "http://213.184.248.43:9099/api/image"

    
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
            
            imageGetter.getImageData(url: imageURL, page: 0, token: mainUser.token!)
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
        displayMyAlertMessage(title: "Succes", message: "Data is succesfully parsed.", called: self)
        
        imageStruct = imageData
        
        for imageItem in imageStruct{
            imageGetter.downloadImage(imageURL: imageItem.url)
        }
    }
    
    func didGetError(errorNumber: Int, errorDiscription: String) {
        displayMyAlertMessage(title: "Ooops", message: "It's an error \(errorNumber) : \(errorDiscription)", called: self)
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
