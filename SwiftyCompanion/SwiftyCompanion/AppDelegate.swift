//
//  AppDelegate.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 11.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        let parameters = ["grant_type" : "client_credentials", "client_id" : "fde0aa7c5eec519a007e41ef35a88a63cd59341544fbdfdc17c9d7762fceb481", "client_secret" : "254a6eaa192270af710cbac115c6ab75a5df68edab025c76913d7494d60100c8"]
//        Alamofire.request("https://api.intra.42.fr/oauth/token", method: .post, parameters: parameters).responseJSON {
//            response in
//            DispatchQueue.main.async {
//                if response.result.isSuccess {
//                    print(response)
//                    let tokenData : JSON = JSON(response.result.value!)
//                    let token = tokenData["access_token"]
//                    KeychainWrapper.standard.set(token.stringValue, forKey: "intraOAuthToken")
//                    print(token.stringValue)
//                } else {
//                    print("Error: \(response.result.error!))")
//                }
//            }
//        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

