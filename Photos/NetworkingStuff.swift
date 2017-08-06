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
}

class NetworkingStuff {
    
    
    fileprivate let delegate: NetworkingStuffDelegate
    
    init(delegate: NetworkingStuffDelegate) {
        self.delegate = delegate
    }
    
    typealias JSONStandart = [String : AnyObject]
    
    let headers : HTTPHeaders = [
        "Content-Type" : "application/json",
        "Accept" : "application/json"
    ]
    
    func authorization(url : String, userName: String, userPassword: String){
        let parameters: Parameters = [
            "login": userName,
            "password": userPassword
        ]
        
        alamofireRequest(url: url, parameters: parameters, headers: headers)
    }
    
    private func authorizationResponse(readableJSON: JSONStandart){
        let login = readableJSON["data"]?["login"]! as! String
        let userId = readableJSON["data"]?["userId"]! as! Int
        let token = readableJSON["data"]?["token"]! as! String
        self.delegate.didGetUser(User(login: login, userId: userId, token: token))
    }

    private func alamofireRequest(url: String, parameters: Parameters, headers: HTTPHeaders){
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding(options: []), headers: headers).responseJSON { (response) in
            
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
                }
                
            }catch {
                print(error)
            }
        }
    }

    
}
