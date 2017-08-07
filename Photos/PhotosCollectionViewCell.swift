//
//  PhotosCollectionViewCell.swift
//  Photos
//
//  Created by Vladislav Shilov on 06.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    //Как тлько в imageStruct в PhotoVC появляется значение мы кидаем его сюда и здесь уже используем
    
    var imageStruct: ImageStruct?{
        didSet{
            self.uppdateCell()
        }
    }
    
    func uppdateCell(){
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
}
