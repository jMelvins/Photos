//
//  PhotosCollectionViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 06.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

//UILongPressGestureRecognizer

import UIKit
import CoreLocation
import CoreData

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
    
    var indexPathToDelete: IndexPath?
    var managedObjectContext: NSManagedObjectContext!
    var photoEntity = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UserDefaults.standard.setValue(false, forKey: "isImagesDownloaded")
        let isImagesDownloaded = UserDefaults.standard.bool(forKey: "isImagesDownloaded")
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        imageGetter = ImageGetter(delegate: self)
        
        //Если нет интернета, загружаем из CoreData
        if Reachability.isConnectedToNetwork() != true || isImagesDownloaded{
            loadFromCoreData()
            print("Internet connection FAILED")
        }
        
        
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let longTab = UILongPressGestureRecognizer(target: self, action: #selector(PhotosCollectionViewController.deleteAction(gestureReconizer:)))
        self.collectionView?.addGestureRecognizer(longTab)
        
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        let isImagesDownloaded = UserDefaults.standard.bool(forKey: "isImagesDownloaded")
        
        if !isUserLoggedIn{
            self.performSegue(withIdentifier: "Auth", sender: self)
        }else {
            mainUser.login = UserDefaults.standard.value(forKey: "userLogin") as? String
            mainUser.userId = UserDefaults.standard.value(forKey: "userId") as? Int
            mainUser.token = UserDefaults.standard.value(forKey: "userToken") as? String
            
            //Если картинки не загружены, то загружаем
            if !isImagesDownloaded{
                imageGetter.getImageData(url: imageURL, page: 0, token: mainUser.token!)
                UserDefaults.standard.set(true, forKey: "isImagesDownloaded")
                UserDefaults.standard.set(true, forKey: "isImagesLoadedToCoreData")
                UserDefaults.standard.synchronize()
            }
            
        }
    }
    
    //MARK: CoreData
    
    func loadFromCoreData(){
        let presentRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        do{
            self.photoEntity = try self.managedObjectContext.fetch(presentRequest)
        }catch{
            print("Couldnt load data from database \(error.localizedDescription)")
        }
        
        for item in photoEntity{
            let dateAsInt = Int((item.date?.timeIntervalSince1970)!)
            print("DateAsInt: \(dateAsInt)")
            let newImage = ImageStruct(id: Int(item.id), url: "url", date: dateAsInt, lat: item.lat, lng: item.lng)
            imageStruct.append(newImage)
        }
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
        
    }
    
    // MARK: DeleteImage
    
    func deleteAction(gestureReconizer: UILongPressGestureRecognizer){
        
        let point = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: point)
        let id = imageStruct[(indexPath?.row)!].id
        indexPathToDelete = indexPath
        
        let myAlert = UIAlertController(title: "Delete image.", message: "Do you want to delete this image?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) in
            self.imageGetter.deleteImage(imageURL: self.imageURL, token: self.mainUser.token!, id: id)
        }
        
        myAlert.addAction(okAction)
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    // MARK: ImageGetterDelegate
    
    func didUploadImage(imageData: ImageStruct) {
        
        //Криво. Будет работать только если картинки грузяться строго по очереди
        if let data = images.last{
            //Использовать этот путь для загрузки из кор даты
            let filename = getDocumentsDirectory().appendingPathComponent("\(imageData.id).png")
            print(filename)
            try? data.write(to: filename)
            
            let photoEntity = Photo(context: managedObjectContext!)
            
            
            let date = Date(timeIntervalSince1970: TimeInterval(imageData.date))
            print("Date: \(date)")
            photoEntity.date = date as NSDate
            photoEntity.lat = imageData.lat
            photoEntity.lng = imageData.lng
            photoEntity.id = Int16(imageData.id)
            
            imageStruct.append(imageData)
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
            do {
                try managedObjectContext?.save()
            } catch  {
                print("Core Data Error: \(error)")
            }
            
        }
        
        
    }
    
    func didDeleteImage() {
        //images.remove(at: (indexPathToDelete?.row)!)
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try managedObjectContext?.fetch(fetchRequest) as! [NSManagedObject]
            
            managedObjectContext.delete(items[(indexPathToDelete?.row)!])
            imageStruct.remove(at: (indexPathToDelete?.row)!)
            
            // Save Changes
            try managedObjectContext?.save()
            
        } catch {
            print(error)
        }
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    
    //Это я сделал для загрузки с сервера,
    //а тепреь нужно добавить такое же и для добаволения с библеотеки
    func didGetImage(image: Data, imageData: ImageStruct) {
        imageStruct.append(imageData)
        
        let filename = getDocumentsDirectory().appendingPathComponent("\(imageData.id).png")
        print(filename)
        try? image.write(to: filename)
        
        let photoEntity = Photo(context: managedObjectContext!)
        
        
        let date = Date(timeIntervalSince1970: TimeInterval(imageData.date))
        print("Date: \(date)")
        photoEntity.date = date as NSDate
        photoEntity.lat = imageData.lat
        photoEntity.lng = imageData.lng
        photoEntity.id = Int16(imageData.id)
        
        do {
            try managedObjectContext?.save()
        } catch  {
            print("Core Data Error: \(error)")
        }
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    //    func didGetImage(image: Data) {
    //        images.append(image)
    //
    //
    //        DispatchQueue.main.async {
    //            self.collectionView?.reloadData()
    //        }
    //    }
    
    //    func didGetImageData(imageData: [ImageStruct]) {
    //
    //        imageStruct += imageData
    //
    //        for imageItem in imageStruct{
    //            imageGetter.downloadImage(imageURL: imageItem.url)
    //        }
    //
    //
    //        //TODO: Вот тут и нужно по идеи сохранять картинку в кор дату
    //        //можно сюда закинуть сохранения в кор дату
    //        //Или нет
    //        //Переписать didGetImage в модели:  в функция загрзки картинки  кидать еще и imageData
    //        //и потом уже в делегате выводить
    //    }
    
    func didGetError(errorNumber: Int, errorDiscription: String) {
        displayMyAlertMessage(title: "Ooops", message: "It's an error \(errorNumber) : \(errorDiscription)", called: self)
    }
    
    // MARK: IBActions
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        
        if Reachability.isConnectedToNetwork() != true {
            displayMyAlertMessage(title: "Networking issue.", message: "You can not appload new images without the internet connection.", called: self)
            return
        }
        
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
        
        location = newLocation
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error: \(error)")
        
    }
    
    //MARK: - Savin image in CoreData
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return images.count
        return imageStruct.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotosCollectionViewCell
        
        cell.imageStruct = imageStruct[indexPath.row]
        //cell.imageView.image = UIImage(data: images[indexPath.row])
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailImageVC" {
            if let indexPath = collectionView?.indexPath(for: sender as! PhotosCollectionViewCell){
                let newVC = segue.destination as! DetailPhotoViewController
                newVC.imageStruct = imageStruct[indexPath.row]
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
            
            var date = 100000
            var lat = 0.1
            var lng = 0.1
            
            if let location = location{
                date = Int((location.timestamp).timeIntervalSince1970)
                lat = (location.coordinate.latitude)
                lng = (location.coordinate.longitude)
            }
            
            imageGetter.uploadImage(imageURL: imageURL, token: mainUser.token!, date: date, lat: Float(lat), lng: Float(lng), imageData: UIImagePNGRepresentation(theImage)!)
            
            //TODO: - Save image in CoreData
            images.append(UIImagePNGRepresentation(theImage)!)
            
            //Нужен специальный индекс для каждоый картинки, например ее ID
            //значит нужно вызывать метож сохранения в кор дату толкьо тогда, когда картинка успешно загруена на сервер
            
            //            if let data = UIImagePNGRepresentation(theImage){
            //                let filename = getDocumentsDirectory().appendingPathComponent("\(mainUser.userId!).png")
            //                try? data.write(to: filename)
            //            }
            
            self.collectionView?.reloadData()
        }
        
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
