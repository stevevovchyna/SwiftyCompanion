//
//  SecondViewController.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 11.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import SwiftyJSON

class SecondViewController: UIViewController {
    
    @IBOutlet weak var specialView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let imageView = UIImageView()
    let usernameLabel = UILabel()
    let emailLabel = UILabel()
    let backButton = UIButton()

    var userData : JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        
        navigationController?.title = "svovchyn's info"
        
        tableView.estimatedRowHeight = 50
        tableView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = UIColor.darkGray
        
        
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)
        imageView.image = UIImage(named: "svovchyn")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        specialView.addSubview(imageView)
        
        usernameLabel.frame = CGRect(x: 10, y: 270, width: UIScreen.main.bounds.size.width, height: 30)
        usernameLabel.text = "Stepan Vovchynudzinskyi"
        usernameLabel.textColor = UIColor.white
        specialView.addSubview(usernameLabel)
        
        emailLabel.frame = CGRect(x: 10, y: 300, width: UIScreen.main.bounds.size.width, height: 30)
        emailLabel.text = "svovchyn@unit.facroty.ua"
        emailLabel.textColor = UIColor.white
        specialView.addSubview(emailLabel)
        
        backButton.frame = CGRect(x: 10, y: 10 + 44, width: 50, height: 50)
        backButton.layer.cornerRadius = 25
        backButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        specialView.addSubview(backButton)

    }
    
    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InfoTableViewCell
        cell.myCellLabel.text = "some random data"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y + 300)
        let height = min(max(y, 200), 400)
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
        emailLabel.frame = CGRect(x: 10, y: y - 44, width: UIScreen.main.bounds.size.width, height: 30)
        usernameLabel.frame = CGRect(x: 10, y: y - 74, width: UIScreen.main.bounds.size.width, height: 30)
        if scrollView.contentOffset.y < -400 {
            scrollView.contentOffset.y = -400
        }
        if scrollView.contentOffset.y > -200 {
            emailLabel.frame = CGRect(x: 10, y: 156, width: UIScreen.main.bounds.size.width, height: 30)
            usernameLabel.frame = CGRect(x: 10, y: 126, width: UIScreen.main.bounds.size.width, height: 30)
        }
    }

}
