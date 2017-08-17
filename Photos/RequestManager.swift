//
//  RequestManager.swift
//  Photos
//
//  Created by Vladislav Shilov on 17.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import Alamofire
import SwiftyJSON

let ApiBaseUrl = "http://213.184.248.43:9099/api"
let ApiMethodGetImage = "/image"
let ApiMethodSignIn = "/account/signin"
let ApiMethodSignUp = "/account/signup"
let ApiMethodGetComment = "/image"

let ReachabilityHost = "213.184.248.43:9099"

// MARK: - Reachability
let serverReachabilityManager: NetworkReachabilityManager? = {
    let manager = NetworkReachabilityManager(host: ReachabilityHost)
    manager?.startListening()
    return manager
}()
let networkReachabilityManager: NetworkReachabilityManager? = {
    let manager = NetworkReachabilityManager()
    manager?.startListening()
    return manager
}()

var isServerConnection : Bool {
    return serverReachabilityManager?.isReachable ?? false
}
var isInternetConnection : Bool {
    return networkReachabilityManager?.isReachable ?? false
}


final class RequestManager {
    
    private class func genericRequest(requestMethod: HTTPMethod,
                                      method : String,
                                      params : [String : Any] = [:],
                                      headers: HTTPHeaders? = nil,
                                      encoding: ParameterEncoding,
                                      success: @escaping (_ responseData: DataResponse<Any>) -> Void = {_ in }){
        if !isInternetConnection{
            print("Network problems")
            return
            
        }
//        if !isServerConnection {
//            print("Server unavailable")
//            return
//        }
        
        let urlString = ApiBaseUrl + method
        
        Alamofire.request(urlString, method: requestMethod, parameters: params, encoding: encoding, headers: headers).responseJSON { response in
            
            print(response.description)
            //TODO
            success(response)
        }
        
//        if(requestMethod == .post){
//            
//
//        }
//        
//        if(requestMethod == .get){
//            
//
//        }
//        
//        if(requestMethod == .delete){
//            
//        }
    }
    
    class func getPhoto(page: Int, token: String, success : @escaping (_ image: [ImageStruct]) -> Void){
        
        let headers : HTTPHeaders = [
            "Accept" : "*/*",
            "Access-Token" : token
        ]
        
        let parameters: Parameters = [
            "page": page,
            "Access-Token": token
        ]
        
        genericRequest(requestMethod: .get, method: ApiMethodGetImage, params: parameters, headers: headers, encoding: URLEncoding.default, success: {
            response in
            guard let value = response.result.value else {
                return
            }
            var image = [ImageStruct]()
            print(response.description)
            let json = JSON(value)
            print("json: \n \(json)")
            let responseData = json["data"]
            image = DataParser.parseImage(data: responseData)
            
            success(image)
        })
    }
    
    class func downloadImage(imageURL: String, success: @escaping (_ image: Data) -> Void){
        
        Alamofire.request(imageURL).downloadProgress(closure: { (Progress) in
            print(Progress.fractionCompleted)
        }).responseData { (DataResponse) in
            
            if let data = DataResponse.result.value{
                print("Image Data: \(data)")
                success(data)
            }
        }
    }

    class func uploadImage(token: String, date: Int, lat: Float, lng: Float, imageData: Data, success: @escaping(_ image: Data, _ imageItem: ImageStruct) -> Void){
        
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

        genericRequest(requestMethod: .post, method: ApiMethodGetImage, params: parameters, headers: headers, encoding: JSONEncoding(options: []), success: { response in
          
            guard let value = response.result.value else {
                return
            }
            var newImage: ImageStruct
            print(response.description)
            let json = JSON(value)
            let responseData = json["data"]
            print(responseData)
            newImage = DataParser.parseSingleImage(data: responseData)
            
            success(imageData, newImage)
        })
    }
    
    class func deleteImage(token: String, id: Int, success: @escaping() -> Void){
        
        let headers : HTTPHeaders = [
            "Accept" : "*/*",
            "Access-Token" : token
        ]
        
        let parameters: Parameters = [
            "id": id,
            "Access-Token": token
        ]
        
        let ApiMethodGetImageDelete = ApiMethodGetImage + "/\(id)"
        
        genericRequest(requestMethod: .delete, method: ApiMethodGetImageDelete, params: parameters, headers: headers, encoding: URLEncoding.default, success: { response in
            print(response)
            success()
        })
    }
    
}





