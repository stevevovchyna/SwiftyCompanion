//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 11.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    var user: User?
    var isRotating : Bool = false
    let oauthManager = OAuthManager()

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
        searchTextField.text = "svovchyn"
        setupColorsAndShadows()
    }
}

extension FirstViewController {
    
    @IBAction func searchUserDataButton(_ sender: UIButton) {
        if searchTextField.text != "" {
            isRotating = true
            rotate42logo()
            oauthManager.userSearchRequests(for: searchTextField.text!.lowercased()) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        self.isRotating = false
                        presentAlert(text: error, in: self)
                        print(error)
                    case .success(let data, let image, let colors):
                        let foundUser = User(data, image, colors)
                        self.isRotating = false
                        self.searchTextField.resignFirstResponder()
                        self.user = foundUser
                        self.performSegue(withIdentifier: "showUserData", sender: self)
                    }
                }
            }
        } else {
            presentAlert(text: "Please enter some text to make a query", in: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserData" {
            let controller = segue.destination as! SecondViewController
            controller.user = user
            if let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
                controller.topInset = interfaceOrientation.isPortrait ? view.safeAreaInsets.top : view.safeAreaInsets.right
            }
        }
    }
    
}

extension FirstViewController {
    
    private func setupColorsAndShadows() {
        loginInputView.layer.cornerRadius = 10
        searchUserDataButtonLabel.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 0.8388270548)
        searchUserDataButtonLabel.layer.cornerRadius = 5
        loginInputView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.8131688784)
        loginInputView.layer.cornerRadius = 10
        UIView.animate(withDuration: 2) {
            self.loginInputView.layer.shadowColor = UIColor.black.cgColor
            self.loginInputView.layer.shadowRadius = 2.0
            self.loginInputView.layer.shadowOpacity = 0.5
            self.loginInputView.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
        addParallaxToView(vw: loginInputView)
    }
    
    private func rotate42logo() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: { () -> Void in
            self.logoImage.transform = self.logoImage.transform.rotated(by: .pi / 2)
        }) { (finished) -> Void in
            if self.isRotating {
                self.rotate42logo()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.logoImage.transform = CGAffineTransform.identity
                }
            }
        }
    }
}

