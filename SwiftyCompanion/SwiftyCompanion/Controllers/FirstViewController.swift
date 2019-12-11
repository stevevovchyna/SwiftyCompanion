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

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchUserDataButtonLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        searchUserDataButtonLabel.isHidden = true
        OAuthManager.getToken { result in
            switch result {
            case .success(let newToken):
                self.token = (newToken["access_token"] as! String)
                UIView.animate(withDuration: 1) {
                    self.searchUserDataButtonLabel.isHidden = false
                }
            case .failure(let error):
                print(error)
                self.presentAlert(text: error.localizedDescription)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    
    @IBAction func searchUserDataButton(_ sender: UIButton) {
        if searchTextField.text != "" {
            OAuthManager.searchUser(query: searchTextField.text!, token: token!) { result in
                switch result {
                case .success(let userData):
                    if userData.count > 0 {
                        self.userData = JSON(userData)
                        self.performSegue(withIdentifier: "showUserData", sender: self)
                    } else {
                        self.presentAlert(text: "User not found!")
                    }
                case .failure(let error):
                    print(error)
                    self.presentAlert(text: error.localizedDescription)
                }
            }
        } else {
            self.presentAlert(text: "Please enter some text to make a query")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserData" {
            let constroller = segue.destination as! SecondViewController
            constroller.userData = userData
        }
    }
    
    func presentAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

