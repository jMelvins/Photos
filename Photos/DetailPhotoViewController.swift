//
//  DetailPhotoViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 07.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit

class DetailPhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    //var imageData: Data?
    var imageStruct: ImageStruct?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let id = imageStruct?.id
        let filename = "\(id!).png"
        print("FiletNAME: \(filename)")
        let photoURL = applicationDocumentsDirectory.appendingPathComponent(filename)
        
        let imageFromFile =  UIImage(contentsOfFile: photoURL.path)
        imageView.image = imageFromFile
        
        let date = Date(timeIntervalSinceNow: TimeInterval((imageStruct?.date)!))
        let littleDate = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        dateLabel.text = "\(littleDate)"

    }
    
}
