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
    var userData : UserData?
    var userImage : UserImage?
    var projectNames : ProjectNames?

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchUserDataButtonLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        searchTextField.text = "svovchyn"
        
        navigationController?.navigationBar.isHidden = true
        searchUserDataButtonLabel.isHidden = true
        OAuthManager.getToken { result in
            switch result {
            case .success(let newToken):
                self.token = (newToken["access_token"] as! String)
                print(self.token ?? "tokena netu")
                UIView.animate(withDuration: 1) {
                    self.searchUserDataButtonLabel.isHidden = false
                }
            case .failure(let error):
                print(error)
                self.presentAlert(text: error.localizedDescription)
            }
        }
//        token = "6aaa77234f2e16d6bcbba6b3671043ba8a2a35ece36ec82fa3482b934076155e"
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
                        self.userData = UserData(userData: JSON(userData), APIToken: self.token ?? "")
                        self.projectNames = ProjectNames(uniqueIDs: self.userData?.uniqueIDs ?? [""], token: self.token ?? "") {
                            self.userImage = UserImage(imageUrl: self.userData?.userImageURL ?? "") {
                                self.performSegue(withIdentifier: "showUserData", sender: self)
                            }
                        }
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
            let controller = segue.destination as! SecondViewController
            controller.userData = userData
            controller.userImage = userImage
            controller.projectNames = projectNames
            controller.topInset = view.safeAreaInsets.top
        }
    }
    
    func presentAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

