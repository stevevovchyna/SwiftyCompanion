//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 11.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FirstViewController: UIViewController {
    
    var token : String?
    var userData : JSON?
    
    let parameters = ["grant_type" : "client_credentials", "client_id" : "fde0aa7c5eec519a007e41ef35a88a63cd59341544fbdfdc17c9d7762fceb481", "client_secret" : "254a6eaa192270af710cbac115c6ab75a5df68edab025c76913d7494d60100c8"]

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchUserDataButtonLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
//        searchUserDataButtonLabel.isHidden = true
        token = "8a1c6ac86598632cc28e8699ad91ebc4c70f309d40991c3940b463df1b3084bc"
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        DispatchQueue.main.async {
//            Alamofire.request("https://api.intra.42.fr/oauth/token", method: .post, parameters: self.parameters).responseJSON {
//                response in
//                    if response.result.isSuccess {
//                        print(response)
//                        let tokenData : JSON = JSON(response.result.value!)
//                        self.token = tokenData["access_token"].stringValue
//                        UIView.animate(withDuration: 0.5) {
//                            self.searchUserDataButtonLabel.isHidden = false
//                        }
//                    } else {
//                        print("Error: Seems like the service is unavailable right now)")
//                    }
//            }
//        }
    }

    @IBAction func searchUserDataButton(_ sender: UIButton) {
        print("tut")
        if searchTextField.text != "" {
            let urlQuery = "https://api.intra.42.fr/v2/users/" + searchTextField.text!
            let params = ["client_id" : "fde0aa7c5eec519a007e41ef35a88a63cd59341544fbdfdc17c9d7762fceb481", "client_secret" : "254a6eaa192270af710cbac115c6ab75a5df68edab025c76913d7494d60100c8"]
            let header = ["Authorization" : "Bearer " + self.token!]
            Alamofire.request(urlQuery, method: .get, parameters: params, headers: header).responseJSON {
                response in
                self.userData = JSON(response.result.value!)
                if response.result.isSuccess, self.userData!.count > 0 {
                    self.performSegue(withIdentifier: "showUserData", sender: self)
                } else {
                    print("Error when requesting user data")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("tam")
        if segue.identifier == "showUserData" {
            let constroller = segue.destination as! SecondViewController
            constroller.userData = userData
        }
    }
    
}

