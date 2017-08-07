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
    
    var imageData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        imageView.image = UIImage(data: imageData!)
    }
    
}
