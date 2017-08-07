//
//  ImageGetter.swift
//  Photos
//
//  Created by Vladislav Shilov on 07.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import Foundation
import Alamofire

protocol ImageGetterDelegate {
    func didGetImageData(imageData: [ImageStruct])
    func didGetError(errorNumber: Int, errorDiscription: String)
}


class ImageGetter {
    
    fileprivate let delegate: ImageGetterDelegate
    
    init(delegate: ImageGetterDelegate) {
        self.delegate = delegate
    }
    
    typealias JSONStandart = [String : AnyObject]
    
    func getImageData(url: String, page: Int, token: String){
        let headers : HTTPHeaders = [
            "Accept" : "*/*",
            "Access-Token" : "b8fOPrUFAGQB8n2evSZ58YmUOdp8flLb8NR24WzOqAY7QZNUUkEi0KsPNgZRfJ81"
        ]
        
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
