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
    //func didGetImageData(imageData: [ImageStruct])
    func didGetError(errorNumber: Int, errorDiscription: String)
    func didGetImage(image: Data, imageData: ImageStruct)
    func didDeleteImage()
    func didUploadImage(imageData: ImageStruct)
}


class ImageGetter {
    
    fileprivate let delegate: ImageGetterDelegate
    
    init(delegate: ImageGetterDelegate) {
        self.delegate = delegate
    }
    
    typealias JSONStandart = [String : AnyObject]
    
    //MARK: Delete Image
    
    func deleteImage(imageURL: String, token: String, id: Int) {
        
        let headers : HTTPHeaders = [
            "Accept" : "*/*",
            "Access-Token" : token
        ]
        
        let parameters: Parameters = [
            "id": id,
            "Access-Token": token
        ]

        let deleteURL = imageURL + "/\(id)"
        
        alamofireRequest(url: deleteURL, parameters: parameters, headers: headers, method: .delete, encoding: URLEncoding.default)
    }
    
    //MARK: Upload Image
    
    func uploadImage(imageURL: String, token: String, date: Int, lat: Float, lng: Float, imageData: Data)  {
       
        let base64Image = imageData.base64EncodedString()
        
        let headers : HTTPHeaders = [
            "Accept" : "application/json;charset=UTF-8",
            "Access-Token" : token
        ]
        
        let parameters: Parameters = [
            "base64Image": base64Image,
            "date": date,
            "lat": lat,
            "lng": lng
        ]
        
        alamofireRequest(url: imageURL, parameters: parameters, headers: headers, method: .post, encoding: JSONEncoding(options: []))
    }
    
    func imageDownloaded(response: AnyObject){
        
        let id = response["id"] as! Int
        let url = response["url"] as! String
        let date = response["date"] as! Int
        let lat = response["lat"] as! Float
        let lng = response["lng"] as! Float
        let imageItem = ImageStruct(id: id, url: url, date: date, lat: lat, lng: lng)
        
        self.delegate.didUploadImage(imageData: imageItem)
    }
    
    //MARK: Download image
    
    func downloadImage(imageURL: String, imageData: ImageStruct){
        
        Alamofire.request(imageURL).downloadProgress(closure: { (Progress) in
            print(Progress.fractionCompleted)
        }).responseData { (DataResponse) in
        
            if let data = DataResponse.result.value{
                print("Image Data: \(data)")
                self.delegate.didGetImage(image: data, imageData: imageData)
            }
        }
    }
    
    //MARK : Get Image JSON
    
    func getImageData(url: String, page: Int, token: String){
        let headers : HTTPHeaders = [
            "Accept" : "*/*",
            "Access-Token" : token
        ]
        
        let parameters: Parameters = [
            "page": page,
            "Access-Token": token
        ]
        alamofireRequest(url: url, parameters: parameters, headers: headers, method: .get, encoding: URLEncoding.default)
    }
    
    private func getImageRespnoce(response: AnyObject){
        print(response)
        var imageArray = [ImageStruct]()
        for index in 0..<response.count{
            let item = response.objectAt(index)
            //let item = response[index] as AnyObject
            
            let id = item["id"] as! Int
            let url = item["url"] as! String
            let date = item["date"] as! Int
            let lat = item["lat"] as! Float
            let lng = item["lng"] as! Float
            let imageItem = ImageStruct(id: id, url: url, date: date, lat: lat, lng: lng)
            
            imageArray.append(imageItem)
        }
        
        
        //значит должны вызывать downloadImage здесь,и толькоп соле загрузки уже делегат
        for item in imageArray{
            downloadImage(imageURL: item.url, imageData: item)
        }
        
        //self.delegate.didGetImageData(imageData: imageArray)
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
                
                //Т.к если мы постим, нам не нужно снова загружать картинку
                guard method != HTTPMethod.post else{
                    if let resp = response.result.value as? JSONStandart{
                        let dictionary = resp["data"] as AnyObject
                        if dictionary.hash != 0{
                            if dictionary["url"] != nil{
                                self.imageDownloaded(response: dictionary)
                                return
                            }
                        }
                    }
                    return
                }
                
                guard method != HTTPMethod.delete else{
                    self.delegate.didDeleteImage()
                    return
                }
                
                if let resp = response.result.value as? JSONStandart{
                    let dictionary = resp["data"] as AnyObject
                    if dictionary.hash != 0{
                        let dictItem = dictionary.objectAt(0)
                        //let dictItem = dictionary[0] as AnyObject
                        if dictItem["url"] != nil{
                            self.getImageRespnoce(response: dictionary)
                            return
                        }
                    }
                }
                
            }catch {
                print(error)
            }
        }
    }
}

