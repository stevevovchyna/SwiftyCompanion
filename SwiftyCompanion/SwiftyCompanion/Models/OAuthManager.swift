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

enum SearchResult<T, U, V> {
    case success(T, U, V)
    case failure(String)
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

enum RequestType {
    case search
    case getImage
    case getCoalition
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

    public func userSearchRequests(for query: String, completion: @escaping (SearchResult<NSDictionary, UIImage, Colors>) -> ()) {
        checkToken { result in
            switch result {
            case .success(let token):
                var userData : NSDictionary?
                var image : UIImage?
                var coalitionColors : Colors?
                
                
                let searchRequest = self.createRequest(for: query, with: token, .search)
                let imageRequest = self.createRequest(for: query, with: token, .getImage)
                let coalitionRequest = self.createRequest(for: query, with: token, .getCoalition)
                
                let operation = DownloadOperation(session: URLSession.shared, dataTaskURLRequest: searchRequest) { (data, response, error) in
                    if let error = error { return completion(.failure(error.localizedDescription)) }
                    guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                        return completion(.failure("Server error"))
                    }
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                        return completion(.failure("There was an issue with the returned data"))
                    }
                    userData = json

                }
                                
                let imageoperation = DownloadOperation(session: URLSession.shared, dataTaskURLRequest: imageRequest) { (data, response, error) in
                    if let error = error { return completion(.failure(error.localizedDescription)) }
                    guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                        return completion(.failure("Server error"))
                    }
                    guard let data = data else { return completion(.failure("There was an issue with the returned data")) }
                    image = UIImage(data: data)
                }

                let coalitionoperation = DownloadOperation(session: URLSession.shared, dataTaskURLRequest: coalitionRequest) { (data, response, error) in
                    if let error = error { return completion(.failure(error.localizedDescription)) }
                    guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                        return completion(.failure("Server error"))
                    }
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSArray else {
                        return completion(.failure("There was an issue with the returned data"))
                    }
                    let coalitionColor = ((json[0] as! NSDictionary)["color"] as! String) + "ff"
                    coalitionColors = self.getCoalitionColorScheme(for: coalitionColor)
                    completion(.success(userData!, image!, coalitionColors!))
                }

                self.queue.addOperation(operation)
                self.queue.addOperation(imageoperation)
                self.queue.addOperation(coalitionoperation)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func checkToken(completion: @escaping (Result<String>) -> ()) {
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
            (createdAt as NSString).doubleValue + (expires_in as NSString).doubleValue > NSDate().timeIntervalSince1970 as Double {
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
    
    private func createRequest(for query: String, with token: String, _ type: RequestType) -> URLRequest {
        var urlString = ""
        switch type {
        case .search:
            urlString = "https://api.intra.42.fr/v2/users/\(query)"
        case .getImage:
            urlString = "https://cdn.intra.42.fr/users/\(query).jpg"
        case .getCoalition:
            urlString = "https://api.intra.42.fr/v2/users/\(query)/coalitions"
        }
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "get"
        let bearer = "Bearer \(token)"
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func getCoalitionColorScheme(for coalitionColor: String) -> Colors {
        switch coalitionColor {
        case "#4caf50ff":
            return Colors(#colorLiteral(red: 0.7058823529, green: 0.8392156863, blue: 0.6784313725, alpha: 0.7714640411), #colorLiteral(red: 0.3647058824, green: 0.5529411765, blue: 0.3647058824, alpha: 0.72), #colorLiteral(red: 0.5333333333, green: 0.7019607843, blue: 0.6745098039, alpha: 0.76), #colorLiteral(red: 0.6470588235, green: 0.07450980392, blue: 0.1137254902, alpha: 0.7))
        case "#673ab7ff":
            return Colors(#colorLiteral(red: 0.6784313725, green: 0.8235294118, blue: 0.9725490196, alpha: 0.3059246575), #colorLiteral(red: 0.7215686275, green: 0.568627451, blue: 0.7568627451, alpha: 0.7), #colorLiteral(red: 0.5529411765, green: 0.1764705882, blue: 0.4, alpha: 0.76), #colorLiteral(red: 0.6784313725, green: 0.8235294118, blue: 0.9725490196, alpha: 0.7))
        case "#f44336ff":
            return Colors(#colorLiteral(red: 1, green: 0.5450980392, blue: 0.462745098, alpha: 0.7), #colorLiteral(red: 1, green: 0.1882352941, blue: 0.1921568627, alpha: 0.7), #colorLiteral(red: 0.5568627451, green: 0, blue: 0.06274509804, alpha: 0.7), #colorLiteral(red: 0.5764705882, green: 0.6, blue: 0.6, alpha: 0.7))
        case "#00bcd4ff":
            return Colors(#colorLiteral(red: 0.8666666667, green: 0.9176470588, blue: 0.9333333333, alpha: 0.7272945205), #colorLiteral(red: 0.1333333333, green: 0.6980392157, blue: 0.9176470588, alpha: 0.7272945205), #colorLiteral(red: 0.5490196078, green: 0.6745098039, blue: 0.8156862745, alpha: 0.7272945205), #colorLiteral(red: 0.8352941176, green: 0.3882352941, blue: 0.3529411765, alpha: 0.7272945205))
        default:
            return Colors(#colorLiteral(red: 0.8666666667, green: 0.9176470588, blue: 0.9333333333, alpha: 0.7272945205), #colorLiteral(red: 0.1333333333, green: 0.6980392157, blue: 0.9176470588, alpha: 0.7272945205), #colorLiteral(red: 0.5490196078, green: 0.6745098039, blue: 0.8156862745, alpha: 0.7272945205), #colorLiteral(red: 0.8352941176, green: 0.3882352941, blue: 0.3529411765, alpha: 0.7272945205))
        }
    }
}
