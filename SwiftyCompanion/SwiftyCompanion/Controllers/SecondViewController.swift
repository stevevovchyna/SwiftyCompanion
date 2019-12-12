//
//  SecondViewController.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 11.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import SwiftyJSON

class myLabel: UILabel {
    
    var textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit() {
        self.layer.cornerRadius = 5
        self.textAlignment = .center
        self.clipsToBounds = true
        self.sizeToFit()
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
}

class SecondViewController: UIViewController {
    
    @IBOutlet var generalView: UIView!
    @IBOutlet weak var specialView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let imageView = UIImageView()
    let usernameLabel = myLabel()
    let emailLabel = myLabel()
    let availabilityLabel = myLabel()
    let backButton = UIButton()
    
    var userData : JSON?
    var topInset : CGFloat?
    var coalitionColor : UIColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    
    var username : String = "svovchyn"
    var emailText : String = "svovchyn@unit.facroty.ua"

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.estimatedRowHeight = 50
        tableView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "LevelTableViewCell", bundle: nil), forCellReuseIdentifier: "levelCell")
        
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)
        imageView.image = UIImage(named: "svovchyn")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        specialView.addSubview(imageView)
        
        usernameLabel.text = username
        usernameLabel.frame = CGRect(x: 10, y: 265, width: 0, height: 0)
        usernameLabel.backgroundColor = coalitionColor
        usernameLabel.textColor = .white
        specialView.addSubview(usernameLabel)
        
        emailLabel.text = emailText
        emailLabel.frame = CGRect(x: 10, y: 300, width: 0, height: 0)
        emailLabel.backgroundColor = coalitionColor
        emailLabel.textColor = .white
        specialView.addSubview(emailLabel)
        
        backButton.frame = CGRect(x: 10, y: 10 + (topInset ?? 0), width: 50, height: 50)
        backButton.layer.cornerRadius = 25
        backButton.setTitle("<", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = coalitionColor
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        specialView.addSubview(backButton)
        
        availabilityLabel.text = "Unavailable"
        availabilityLabel.sizeToFit()
        let labelWidth = availabilityLabel.frame.size.width
        availabilityLabel.frame.origin = CGPoint(x: UIScreen.main.bounds.size.width - labelWidth - 10, y: 10 + (topInset ?? 0))
        availabilityLabel.backgroundColor = coalitionColor
        availabilityLabel.textColor = .white
        specialView.addSubview(availabilityLabel)

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
        switch indexPath.row {
        case 0:
            let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
            levelCell.levelLabel.text = "level - 10,45%"
            levelCell.backgroundLabel.backgroundColor = coalitionColor
            let rightInset = UIScreen.main.bounds.size.width - (UIScreen.main.bounds.size.width / 21) * 10.45
            levelCell.rightConstraint.constant = rightInset
            return levelCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InfoTableViewCell
            cell.myCellLabel.text = "some random data"
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y + 300)
        let height = min(max(y, 200), 400)
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
        emailLabel.frame = CGRect(x: 10, y: y - 44, width: 0, height: 0)
        usernameLabel.frame = CGRect(x: 10, y: y - 79, width: 0, height: 0)
        usernameLabel.sizeToFit()
        emailLabel.sizeToFit()
        if scrollView.contentOffset.y < -400 {
            scrollView.contentOffset.y = -400
        }
        if scrollView.contentOffset.y > -200 {
            emailLabel.frame = CGRect(x: 10, y: 156, width: 0, height: 0)
            usernameLabel.frame = CGRect(x: 10, y: 121, width: 0, height: 0)
            usernameLabel.sizeToFit()
            emailLabel.sizeToFit()
        }
    }

}
