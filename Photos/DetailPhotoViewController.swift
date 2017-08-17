//
//  DetailPhotoViewController.swift
//  Photos
//
//  Created by Vladislav Shilov on 07.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit

class DetailPhotoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UIBarButtonItem!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    let asd = "http://213.184.248.43:9099/swagger-ui.html#!/Comments/getCommentsUsingGET"
    let commentsURL = "http://213.184.248.43:9099/api/image"
    
    //var imageData: Data?
    var imageStruct: ImageStruct?
    let comments = ["123", "cool", "awesome", "asdasd", "qweqwe", "dv,x,lsa"]
    
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
        
        let date = Date(timeIntervalSince1970: TimeInterval((imageStruct?.date)!))
        let littleDate = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        dateLabel.text = "\(littleDate)"
    }
    
    @IBAction func sendComment(_ sender: Any) {
        
        //TODO
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath)
        
        cell.textLabel?.text = comments[indexPath.row]
        
        return cell
    }
    
}






