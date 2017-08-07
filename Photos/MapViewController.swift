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
    
    let name: String?
    let disription: String?
    let location: CLLocationCoordinate2D
    
    init(name: String, discription: String, location: CLLocationCoordinate2D) {
        self.name = name
        self.disription = discription
        self.location = location
    }
    
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    //@IBOutlet weak var mapView: GMSMapView?
    
    var managedObjectContext: NSManagedObjectContext!
    var mapView: GMSMapView?
    var mapEntity = [MapItem]()
    
    var destinations = [Destination]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        loadFromCoreData()
        
        for item in mapEntity{
            let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(item.latitude), longitude: CLLocationDegrees(item.longitude))
            let newDest = Destination(name: item.discription!, discription: item.name!, location: coord)
            
            destinations.append(newDest)
        }
        
        
        let camera = GMSCameraPosition.camera(withTarget: (destinations[0].location), zoom: 14)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView?.mapType = GMSMapViewType.hybrid
        mapView?.isMyLocationEnabled = true
        
        view = mapView
        
        createMarkers()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(MapViewController.currentLocationAction))
        
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
        let presentRequest:NSFetchRequest<MapItem> = MapItem.fetchRequest()
        do{
            self.mapEntity = try self.managedObjectContext.fetch(presentRequest)
        }catch{
            print("Couldnt load data from database \(error.localizedDescription)")
        }
    }
    
    
    //MARK: GM
    
    func createMarkers(){
        
        // Creates a marker in the center of the map.
        
        for item in destinations{
            let newMarker = GMSMarker()
            newMarker.position = item.location
            newMarker.title = item.name
            newMarker.snippet = item.disription
            newMarker.map = mapView
        }
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
