//
//  OAuthManager.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 11.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit

enum KeyChainOption<T> {
    case save(T)
    case update(T)
}

enum Result<T> {
    case success(T)
    case failure(String)
}

enum OperationState : Int {
    case ready
    case executing
    case finished
}

class DownloadOperation : Operation {
    
    private var task : URLSessionDataTask!
    private var state : OperationState = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }
    init(session: URLSession, dataTaskURLRequest: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        super.init()
        task = session.dataTask(with: dataTaskURLRequest, completionHandler: { [weak self] (data, response, error) in
            if let completionHandler = completionHandler {
                completionHandler(data, response, error)
            }
            self?.state = .finished
        })
    }

    override func start() {
        if self.isCancelled {
            state = .finished
            return
        }
        state = .executing
        self.task.resume()
    }

    override func cancel() {
        super.cancel()
        self.task.cancel()
    }
}

class OAuthManager {
    
    private let client_id = "fde0aa7c5eec519a007e41ef35a88a63cd59341544fbdfdc17c9d7762fceb481"
    private let client_secret = "254a6eaa192270af710cbac115c6ab75a5df68edab025c76913d7494d60100c8"
    private let queue = OperationQueue()
    
    init() {
        queue.maxConcurrentOperationCount = 1
    }

    public func userSearchRequest(for query: String, completion: @escaping (Result<NSDictionary>) -> ()) {
        checkToken { result in
            switch result {
            case .success(let token):
                let urlString = "https://api.intra.42.fr/v2/users/" + query
                let url = URL(string: urlString)
                var request = URLRequest(url: url!)
                request.httpMethod = "get"
                let bearer = "Bearer \(token)"
                request.setValue(bearer, forHTTPHeaderField: "Authorization")
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        return completion(.failure(error.localizedDescription))
                    }
                    guard let respons = response as? HTTPURLResponse, (200...299).contains(respons.statusCode) else {
                        return completion(.failure("Server error"))
                    }
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                        return completion(.failure("There was an issue with the returned data"))
                    }
                    completion(.success(json))
                }.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
//    public func searchRequest(query: String, token: String, completion: @escaping (Result<[String: Any]>) -> Void) {
//        let urlQuery = "https://api.intra.42.fr/v2/users/" + query
//        let header = ["Authorization" : "Bearer " + token]
//        Alamofire.request(urlQuery, method: .get, parameters: self.parameters, headers: header).responseJSON { response in
//            switch response.result {
//            case .success(let value as [String: Any]):
//                completion(.success(value))
//            case .failure(let error):
//                completion(.failure(error))
//            default:
//                fatalError("received non-dictionary JSON response")
//            }
//        }
//    }
    
    private func checkToken(completion: @escaping (Result<String>) -> ()) {
        let currentTime = NSDate().timeIntervalSince1970 as Double
        if retrieveTokenFromKeychain(for: "access_token") == nil,
            retrieveTokenFromKeychain(for: "created_at") == nil,
            retrieveTokenFromKeychain(for: "expires_in") == nil {
            getToken { result in
                switch result {
                case .success(let tokenData):
                    self.keyChainAction(.save(tokenData))
                    completion(.success(tokenData["access_token"] as! String))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else if let oldToken = retrieveTokenFromKeychain(for: "access_token"),
            let createdAt = retrieveTokenFromKeychain(for: "created_at"),
            let expires_in = retrieveTokenFromKeychain(for: "expires_in"),
            currentTime - (createdAt as NSString).doubleValue < (expires_in as NSString).doubleValue {
            completion(.success(oldToken))
        } else {
            getToken { result in
                switch result {
                case .success(let tokenData):
                    self.keyChainAction(.update(tokenData))
                    completion(.success(tokenData["access_token"] as! String))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getToken(completion: @escaping (Result<NSDictionary>) -> Void) {
        let urlString = "https://api.intra.42.fr/oauth/token"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials&client_id=\(client_id)&client_secret=\(client_secret)".data(using: String.Encoding.utf8)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                return completion(.failure(error.localizedDescription))
            }
            guard let respons = response as? HTTPURLResponse, (200...299).contains(respons.statusCode) else {
                return completion(.failure("Server error"))
            }
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                return completion(.failure("There was an issue with the returned data"))
            }
            completion(.success(json))
        }.resume()
    }
    
    private func keyChainAction(_ action: KeyChainOption<NSDictionary>) {
        switch action {
        case .save(let token):
            let keyItems = ["access_token": token["access_token"] as! String,
                            "created_at": String(token["created_at"] as! Double),
                            "expires_in": String(token["expires_in"] as! Double)]
            for keyItem in keyItems {
                saveToKeychain(keyItem.value, for: keyItem.key)
            }
        case .update(let token):
            let keyItems = ["access_token": token["access_token"] as! String,
                            "created_at": String(token["created_at"] as! Double),
                            "expires_in": String(token["expires_in"] as! Double)]
            for keyItem in keyItems {
                updateTokenInKeychain(keyItem.value, for: keyItem.key)
            }
        }
    }
}
