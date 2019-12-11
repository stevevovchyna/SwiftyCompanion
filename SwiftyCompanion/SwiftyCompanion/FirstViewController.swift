//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 11.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchUserDataButtonLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true

    }

    @IBAction func searchUserDataButton(_ sender: UIButton) {
        if searchTextField.text != "" {
            performSegue(withIdentifier: "showUserData", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserData" {
            let constroller = segue.destination as! SecondViewController
            constroller.someData = searchTextField.text ?? "field is empty"
        }
    }
    
}

