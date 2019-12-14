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
    var userCoalition : Coalition?

    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchUserDataButtonLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rotator()
        
        
        searchTextField.text = "svovchyn"
        
//        searchUserDataButtonLabel.isHidden = true
//        OAuthManager.getToken { result in
//            switch result {
//            case .success(let newToken):
//                self.token = (newToken["access_token"] as! String)
//                print(self.token ?? "tokena netu")
//                UIView.animate(withDuration: 1) {
//                    self.searchUserDataButtonLabel.isHidden = false
//                }
//            case .failure(let error):
//                print(error)
//                self.presentAlert(text: error.localizedDescription)
//            }
//        }
        token = "4e4ef9071a4f594c7ef83c2657dc5f00a94f0524bd4dfac77a0a72de50ed2118"
    }
    
    func rotator() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: { () -> Void in
            self.logoImage.transform = self.logoImage.transform.rotated(by: .pi / 2)
        }) { (finished) -> Void in
            self.rotator()
        }
    }
}

extension FirstViewController {
    
    @IBAction func searchUserDataButton(_ sender: UIButton) {
        if searchTextField.text != "" {
            OAuthManager.searchUser(query: searchTextField.text!, token: token!) { result in
                switch result {
                case .success(let userData):
                    if userData.count > 0 {
                        self.userData = UserData(userData: JSON(userData))
                        self.userCoalition = Coalition(userID: self.searchTextField.text!, token: self.token!) {
                            self.projectNames = ProjectNames(uniqueIDs: self.userData?.uniqueIDs ?? [""], token: self.token ?? "") {
                                self.userImage = UserImage(imageUrl: self.userData?.userImageURL ?? "") {
                                    self.performSegue(withIdentifier: "showUserData", sender: self)
                                }
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
            controller.userCoalition = userCoalition
//            if UIApplication.shared.statusBarOrientation.isLandscape {
//                controller.topInset = view.safeAreaInsets.top
//                print("land")
//            } else {
//                controller.topInset = view.safeAreaInsets.right
//                print("side")
//            }
            if let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
                controller.topInset = interfaceOrientation.isPortrait ? view.safeAreaInsets.top : view.safeAreaInsets.right
            }
        }
    }
    
    func presentAlert(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

