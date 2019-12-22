//
//  OAuthManager.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 11.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

enum KeyChainOption {
    case save
    case update
}

class OAuthManager {
    
    static let clientID = "fde0aa7c5eec519a007e41ef35a88a63cd59341544fbdfdc17c9d7762fceb481"
    static let clientSecret = "254a6eaa192270af710cbac115c6ab75a5df68edab025c76913d7494d60100c8"
    static var parameters = ["client_id" : clientID, "client_secret" : clientSecret]
    
    static func getToken(completionHandler: @escaping (Result<[String: Any]>) -> Void) {
        let url = "https://api.intra.42.fr/oauth/token"
        var params = self.parameters
        params["grant_type"] = "client_credentials"
        Alamofire.request(url, method: .post, parameters: params).responseJSON { response in
                switch response.result {
                case .success(let value as [String: Any]):
                    completionHandler(.success(value))
                case .failure(let error):
                    completionHandler(.failure(error))
                default:
                    fatalError("received non-dictionary JSON response")
                }
        }
    }
    
    static func tokenIsValid() -> Bool {
        let Keys = KeychainManager()
        guard let createdAt = Keys.retrieveToken(for: "created_at") else { return false }
        guard let expires_in = Keys.retrieveToken(for: "expires_in") else { return false }
        let currentTime = NSDate().timeIntervalSince1970 as Double
        let diff = currentTime - (createdAt as NSString).doubleValue
        return diff > (expires_in as NSString).doubleValue ? false : true
    }
    
    static func searchRequest(query: String, token: String, completion: @escaping (Result<[String: Any]>) -> Void) {
        let urlQuery = "https://api.intra.42.fr/v2/users/" + query
        let header = ["Authorization" : "Bearer " + token]
        Alamofire.request(urlQuery, method: .get, parameters: self.parameters, headers: header).responseJSON { response in
            switch response.result {
            case .success(let value as [String: Any]):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            default:
                fatalError("received non-dictionary JSON response")
            }
        }
    }
    
    static func keyChainAction(_ action: KeyChainOption, withElements keys: [String : String]) {
        let KeysManager = KeychainManager()
        switch action {
        case .save:
            for keyItem in keys {
                KeysManager.save(keyItem.value, for: keyItem.key)
            }
        case .update:
            for keyItem in keys {
                KeysManager.updateToken(keyItem.value, for: keyItem.key)
            }
        }
    }

    static func searchUser(query: String, completionHandler: @escaping (Result<[String: Any]>) -> Void) {
        
        let Keys = KeychainManager()
        
        if let oldToken = Keys.retrieveToken(for: "access_token") {
            switch tokenIsValid() {
            case true:
                searchRequest(query: query, token: oldToken) { response in
                    completionHandler(response)
                }
            case false:
                getToken { result in
                    switch result {
                    case .success(let newToken):
                        let token = JSON(newToken)
                        let keysArray = ["access_token": token["access_token"].stringValue,
                                         "created_at": token["created_at"].stringValue,
                                         "expires_in": token["expires_in"].stringValue]
                        keyChainAction(.update, withElements: keysArray)
                        searchRequest(query: query, token: token["access_token"].stringValue) { response in
                            completionHandler(response)
                        }
                    case .failure(let error):
                        print(error)
                        completionHandler(.failure(error))
                    }
                }
            }
        } else {
            getToken { result in
                switch result {
                case .success(let newToken):
                    let token = JSON(newToken)
                    let keysArray = ["access_token": token["access_token"].stringValue,
                                     "created_at": token["created_at"].stringValue,
                                     "expires_in": token["expires_in"].stringValue]
                    keyChainAction(.save, withElements: keysArray)
                    searchRequest(query: query, token: token["access_token"].stringValue) { response in
                        completionHandler(response)
                    }
                case .failure(let error):
                    print(error)
                    completionHandler(.failure(error))
                }
            }
        }
    }
}
