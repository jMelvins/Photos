//
//  NetworkingStuff.swift
//  Photos
//
//  Created by Vladislav Shilov on 05.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkingStuffDelegate {
    func didGetUser(_ user: User)
    func didGetError(errorNumber: Int, errorDiscription: String)
    func didGetImageData(imageData: [ImageStruct])
}

class NetworkingStuff {
    
    
    fileprivate let delegate: NetworkingStuffDelegate
    
    init(delegate: NetworkingStuffDelegate) {
        self.delegate = delegate
    }
    
    typealias JSONStandart = [String : AnyObject]
    
//    let headers : HTTPHeaders = [
//        "Content-Type" : "application/json",
//        "Accept" : "application/json"
//    ]
    
    func getImageData(url: String){
        let headers : HTTPHeaders = [
            "Accept" : "*/*",
            "Access-Token" : "b8fOPrUFAGQB8n2evSZ58YmUOdp8flLb8NR24WzOqAY7QZNUUkEi0KsPNgZRfJ81"
        ]
        
        let page = 0
        let token = "b8fOPrUFAGQB8n2evSZ58YmUOdp8flLb8NR24WzOqAY7QZNUUkEi0KsPNgZRfJ81"
        let parameters: Parameters = [
            "page": page,
            "Access-Token": token
        ]
        alamofireRequest(url: url, parameters: parameters, headers: headers, method: .get, encoding: URLEncoding.default)
    }
    
    private func getImageRespnce(response: AnyObject){
        print(response)
        var imageArray = [ImageStruct]()
        for index in 0..<response.count{
            let item = response[index] as AnyObject
            
            let id = item["id"] as! Int
            let url = item["url"] as! String
            let date = item["date"] as! Int
            let lat = item["lat"] as! Float
            let lng = item["lng"] as! Float
            let imageItem = ImageStruct(id: id, url: url, date: date, lat: lat, lng: lng)
            
            imageArray.append(imageItem)
        }
        
        self.delegate.didGetImageData(imageData: imageArray)
    }
    
    func authorization(url : String, userName: String, userPassword: String){
        let headers : HTTPHeaders = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        
        let parameters: Parameters = [
            "login": userName,
            "password": userPassword
        ]
        
        alamofireRequest(url: url, parameters: parameters, headers: headers, method: .post, encoding: JSONEncoding(options: []))
    }
    
    private func authorizationResponse(readableJSON: JSONStandart){
        let login = readableJSON["data"]?["login"]! as! String
        let userId = readableJSON["data"]?["userId"]! as! Int
        let token = readableJSON["data"]?["token"]! as! String
        self.delegate.didGetUser(User(login: login, userId: userId, token: token))
    }

    private func alamofireRequest(url: String, parameters: Parameters, headers: HTTPHeaders, method: HTTPMethod, encoding: ParameterEncoding){
        
        
        Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { (response) in
            
            guard response.result.isSuccess else{
                print("Error while fetching remote rooms: \(response.result.error!)")
                return
            }
            
            let JSONData = response.data!
            do {
                let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as? JSONStandart
                
                guard readableJSON?["status"] as? Int == 200 else{
                    let errorNumber = readableJSON?["status"] as! Int
                    let errorDiscription = readableJSON?["error"] as! String
                    self.delegate.didGetError(errorNumber: errorNumber, errorDiscription: errorDiscription)
                    return
                }
                
                if readableJSON?["data"]?["login"] != nil{
                    self.authorizationResponse(readableJSON: readableJSON!)
                    return
                }
                
                if let resp = response.result.value as? JSONStandart{
                    let dictionary = resp["data"] as AnyObject
                    let dictItem = dictionary[0] as AnyObject
                    if dictItem["url"] != nil{
                        self.getImageRespnce(response: dictionary)
                        return
                    }
                }
                
            }catch {
                print(error)
            }
        }
    }

    
}
