//
//  MapViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 07.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreData

class Destination: NSObject {
    
    let address: String?
    let location: CLLocationCoordinate2D
    let phoneNumber: String?
    
    init(address: String, location: CLLocationCoordinate2D, phoneNumber: String) {
        self.address = address
        self.location = location
        self.phoneNumber = phoneNumber
    }
    
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    //@IBOutlet weak var mapView: GMSMapView?
    
    var managedObjectContext: NSManagedObjectContext!
    var mapView: GMSMapView?
    var mapEntity = [Map]()
    
    //var destinations = [Destination]()
    
    let destinations = [Destination.init(address: "I Study here!",
                                         location: CLLocationCoordinate2D   (latitude: 53.918855, longitude: 27.593690),
                                         phoneNumber: "+375 (25) 679 57 11"),
                        Destination.init(address: "My potintial job.",
                                         location: CLLocationCoordinate2D   (latitude: 53.904847, longitude: 27.588140),
                                         phoneNumber: "+375 (44) 5 666 713"),
                        Destination.init(address: "I can live here.",
                                         location: CLLocationCoordinate2D   (latitude: 53.910219, longitude: 27.592335),
                                         phoneNumber: "+375 (25) 679 57 11"),
                        Destination.init(address: "Minsk, vulica Zaslaŭskaja 17",
                                         location: CLLocationCoordinate2D   (latitude: 53.909145, longitude: 27.538518),
                                         phoneNumber: "+375 (33) 123 45 67"),
                        Destination.init(address: "Minsk, Kastryčnickaja Square",
                                         location: CLLocationCoordinate2D   (latitude: 53.902686, longitude: 27.561302),
                                         phoneNumber: "+375 (29) 987 65 43"),]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
//        loadFromCoreData()
        
//        for item in mapEntity{
//            let coord = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
//            let newDest = Destination(discription: item.discription!, location: coord)
//            
//            destinations.append(newDest)
//        }
        
        
        let camera = GMSCameraPosition.camera(withTarget: (destinations[0].location), zoom: 14)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView?.mapType = GMSMapViewType.hybrid
        mapView?.isMyLocationEnabled = true
        
        view = mapView
        
        createMarkers()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(MapViewController.currentLocationAction))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(MapViewController.currentLocationAction))
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CoreData
    
    func loadFromCoreData(){
        let presentRequest:NSFetchRequest<Map> = Map.fetchRequest()
        do{
            self.mapEntity = try self.managedObjectContext.fetch(presentRequest)
        }catch{
            print("Couldnt load data from database \(error.localizedDescription)")
        }
    }
    
    
    //MARK: GM
    
    func createMarkers(){
        
        // Creates a marker in the center of the map.
//        
//        for item in destinations{
//            let newMarker = GMSMarker()
//            newMarker.position = item.location
//            newMarker.title = item.disription
//            newMarker.map = mapView
//        }
        
        let bsuirMarker = GMSMarker()
        bsuirMarker.position = destinations[0].location
        bsuirMarker.title = destinations[0].phoneNumber
        bsuirMarker.snippet = destinations[0].address
        bsuirMarker.map = mapView
        
        let jobMarker = GMSMarker()
        jobMarker.position = destinations[1].location
        jobMarker.title = destinations[1].phoneNumber
        jobMarker.snippet = destinations[1].address
        jobMarker.map = mapView
        
        let apartmentMarker = GMSMarker()
        apartmentMarker.position = destinations[2].location
        apartmentMarker.title = destinations[2].phoneNumber
        apartmentMarker.snippet = destinations[2].address
        apartmentMarker.map = mapView
        
        let RandomPos = GMSMarker()
        RandomPos.position = destinations[3].location
        RandomPos.title = destinations[3].phoneNumber
        RandomPos.snippet = destinations[3].address
        RandomPos.map = mapView
        
        let RandomPos1 = GMSMarker()
        RandomPos1.position = destinations[4].location
        RandomPos1.title = destinations[4].phoneNumber
        RandomPos1.snippet = destinations[4].address
        RandomPos1.map = mapView
    }
    
    func currentLocationAction(){
        if let mylocation = mapView?.myLocation {
            print("User's location: \(mylocation)")
            setMapCamera(target: mylocation.coordinate, zoom: 14.0)
        } else {
            print("User's location is unknown")
        }
    }
    
    private func setMapCamera(target: CLLocationCoordinate2D, zoom: Float) {
        
        //Delay
        CATransaction.begin()
        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        
        mapView?.animate(to: GMSCameraPosition.camera(withTarget: target, zoom: zoom))
        
        CATransaction.commit()
        
        //mapView?.camera = GMSCameraPosition.camera(withTarget: (currentDestination?.location)!, zoom: (currentDestination?.zoom)!)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
