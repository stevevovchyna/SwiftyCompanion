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
    var isRotating : Bool = false

    @IBOutlet weak var logoImage: UIImageView!
    

    @IBOutlet weak var generalView: UIView!
    @IBOutlet weak var loginInputView: UIView!
    @IBOutlet weak var searchTextField: MyCustomTextField!
    @IBOutlet weak var searchUserDataButtonLabel: UIButton!
    
    override func viewWillLayoutSubviews() {
        searchTextField.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        searchTextField.text = "svovchyn"
        
        loginInputView.backgroundColor = .clear
        loginInputView.layer.cornerRadius = 10
        
        searchUserDataButtonLabel.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.7411764706, blue: 0.5450980392, alpha: 0.867374786)
        searchUserDataButtonLabel.layer.cornerRadius = 5
        
        loginInputView.backgroundColor = #colorLiteral(red: 0, green: 0.2980392157, blue: 0.337254902, alpha: 0.867374786)
        loginInputView.layer.cornerRadius = 10
        UIView.animate(withDuration: 2) {
            self.loginInputView.layer.shadowColor = UIColor.black.cgColor
            self.loginInputView.layer.shadowRadius = 2.0
            self.loginInputView.layer.shadowOpacity = 0.5
            self.loginInputView.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
        addParallaxToView(vw: loginInputView)
    }
}

extension FirstViewController {
    
    @IBAction func searchUserDataButton(_ sender: UIButton) {
        if searchTextField.text != "" {
            isRotating = true
            rotator()
            
            OAuthManager.searchUser(query: searchTextField.text!) { result in
                switch result {
                case .success(let userData):
                    if userData.count > 0 {
                        self.userData = UserData(userData: JSON(userData))
                        self.userCoalition = Coalition(userID: self.searchTextField.text!) {
                            self.projectNames = ProjectNames(uniqueIDs: self.userData?.uniqueIDs ?? [""]) {
                                self.userImage = UserImage(imageUrl: self.userData?.userImageURL ?? "") {
                                    self.isRotating = false
                                    self.searchTextField.resignFirstResponder()
                                    self.performSegue(withIdentifier: "showUserData", sender: self)
                                }
                            }
                        }
                    } else {
                        self.isRotating = false
                        self.presentAlert(text: "User not found!")
                    }
                case .failure(let error):
                    print(error)
                    self.isRotating = false
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
    
    func rotator() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: { () -> Void in
            self.logoImage.transform = self.logoImage.transform.rotated(by: .pi / 2)
        }) { (finished) -> Void in
            if self.isRotating {
                self.rotator()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.logoImage.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
}

