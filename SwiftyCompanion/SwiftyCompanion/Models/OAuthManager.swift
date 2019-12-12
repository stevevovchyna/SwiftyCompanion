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
    
    static func searchUser(query: String, token: String, completionHandler: @escaping (Result<[String: Any]>) -> Void) {
        let urlQuery = "https://api.intra.42.fr/v2/users/" + query
        let header = ["Authorization" : "Bearer " + token]
        Alamofire.request(urlQuery, method: .get, parameters: self.parameters, headers: header).responseJSON { response in
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
    
    static func searchPiscine(query: String, token: String, completionHandler: @escaping (Result<[String: Any]>) -> Void) {
        let urlQuery = "https://api.intra.42.fr/v2/projects/" + query
        let header = ["Authorization" : "Bearer " + token]
        Alamofire.request(urlQuery, method: .get, parameters: self.parameters, headers: header).responseJSON { response in
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
    
}
