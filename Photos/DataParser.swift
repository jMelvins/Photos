//
//  DataParser.swift
//  Photos
//
//  Created by Vladislav Shilov on 17.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import SwiftyJSON

final class DataParser {
    
    class func parseImage(data: JSON) -> [ImageStruct]{
        var image = [ImageStruct]()
        
        for item in data.array! {
            let id = item["id"].stringValue
            let url = item["url"].stringValue
            let date = item["date"].stringValue
            let lat = item["lat"].stringValue
            let lng = item["lng"].stringValue
            let imageItem = ImageStruct(id: Int(id)!, url: url, date: Int(date)!, lat: Float(lat)!, lng: Float(lng)!)
            
            image.append(imageItem)
        }
        return image
    }
    
    class func parseSingleImage(data: JSON) -> ImageStruct{
        
        let id = data["id"].stringValue
        let url = data["url"].stringValue
        let date = data["date"].stringValue
        let lat = data["lat"].stringValue
        let lng = data["lng"].stringValue
        let imageItem = ImageStruct(id: Int(id)!, url: url, date: Int(date)!, lat: Float(lat)!, lng: Float(lng)!)
        
        return imageItem
    }
    
    class func parseUser(data: JSON) -> User{
        
        let login = data["login"].stringValue
        let userId = data["userId"].stringValue
        let token = data["token"].stringValue
        let user = User(login: login, userId: Int(userId), token: token)
        
        return user
    }
    
}
