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
    
    var userData : UserData?
    var topInset : CGFloat?
    var coalitionColor : UIColor = #colorLiteral(red: 0.4692698717, green: 0.6561034322, blue: 0.4752988815, alpha: 0.8)

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        userData?.description()
        
        specialView.backgroundColor = coalitionColor
        
        tableView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "LevelTableViewCell", bundle: nil), forCellReuseIdentifier: "levelCell")
        tableView.register(UINib(nibName: "GeneralDataTableViewCell", bundle: nil), forCellReuseIdentifier: "generalDataCell")
        
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)
//        imageView.image = UIImage(named: "svovchyn")
        DispatchQueue.main.async {
            self.imageView.image = UIImage(data: self.userData!.userImage)
            print("privetiki")
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        specialView.addSubview(imageView)
        
        usernameLabel.text = userData?.username
        usernameLabel.frame = CGRect(x: 10, y: 265, width: 0, height: 0)
        usernameLabel.backgroundColor = coalitionColor
        usernameLabel.textColor = .white
        specialView.addSubview(usernameLabel)
        
        emailLabel.text = userData?.email
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
    
    func randomColor() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
    }
    
}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + (userData?.projects.count ?? 0) + (userData?.skills.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let skillsCount = userData?.skills.count ?? 0
        let projectsCount = userData?.projects.count ?? 0
        switch indexPath.row {
        case 0:
            let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
            let floatLevel = ((userData?.level ?? "0") as NSString).floatValue
            levelCell.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 0.6982288099)
            levelCell.cellHeight.constant = 44
            levelCell.levelLabel.text = String(format: "%.2f%", floatLevel)
            levelCell.backgroundLabel.backgroundColor = coalitionColor
            let rightInset = UIScreen.main.bounds.size.width - (UIScreen.main.bounds.size.width / 21) * CGFloat(floatLevel)
            levelCell.rightConstraint.constant = rightInset
            return levelCell
        case 1:
            let generalCell = tableView.dequeueReusableCell(withIdentifier: "generalDataCell", for: indexPath) as! GeneralDataTableViewCell
            generalCell.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 0.5)
            generalCell.fullNameLabel.text = "\(userData?.firstName ?? "Somebody") \(userData?.lastName ?? "Somebody")"
            generalCell.phoneNumberLabel.text = userData?.phone
            generalCell.evaluationPointsLabel.text = userData?.evaluationPoints
            generalCell.gradeLabel.text = userData?.grade
            generalCell.walletLabel.text = userData?.wallets
            generalCell.poolYearLabel.text = userData?.poolYear
            return generalCell
        case 2:
            let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
            levelCell.cellHeight.constant = 30
            levelCell.levelLabel.text = "Skills"
            levelCell.backgroundLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            levelCell.levelLabel.textColor = .white
            levelCell.rightConstraint.constant = 0
            return levelCell
        case 3...skillsCount + 2:
            let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
            if let skill = userData?.skills[indexPath.row - 3] {
                levelCell.levelLabel.text = "\(skill.skillName) - \(skill.skillLevel)"
                let rightInset = UIScreen.main.bounds.size.width - ((UIScreen.main.bounds.size.width / 20) * CGFloat(Double(skill.skillLevel) ?? 0))
                levelCell.rightConstraint.constant = rightInset
            } else {
                levelCell.levelLabel.text = "No data"
            }
            levelCell.levelLabel.textColor = .black
            levelCell.backgroundLabel.backgroundColor = randomColor()
            levelCell.cellHeight.constant = 20
            levelCell.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 0.6982288099)
            return levelCell
        case skillsCount + 3:
            let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
            levelCell.cellHeight.constant = 30
            levelCell.levelLabel.text = "Projects"
            levelCell.backgroundLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            levelCell.levelLabel.textColor = .white
            levelCell.rightConstraint.constant = 0
            return levelCell
        case skillsCount + 4...projectsCount + skillsCount + 3:
            let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
            if let project = userData?.projects[indexPath.row - (skillsCount + 4)] {
                let possibleParent = project.projectIsInPiscine ? "\(userData?.projectNames[project.projectParentID!] ?? "No data") " : ""
                levelCell.levelLabel.text = possibleParent + "\(project.projectName) - \(project.projectFinalMark)"
                levelCell.backgroundLabel.backgroundColor = project.projectIsValidated ? #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1) : #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                if project.projectFinalMark != "0", project.projectFinalMark != "-42" {
                    let rightInset = UIScreen.main.bounds.size.width - ((UIScreen.main.bounds.size.width / 125) * CGFloat(Double(project.projectFinalMark) ?? 0))
                    levelCell.rightConstraint.constant = rightInset
                }
            } else {
                levelCell.levelLabel.text = "No data"
                levelCell.backgroundLabel.backgroundColor = coalitionColor
            }
            levelCell.levelLabel.textColor = .black
            levelCell.cellHeight.constant = 20
            levelCell.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 0.6982288099)
            return levelCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InfoTableViewCell
            cell.myCellLabel.text = "some random data"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
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
