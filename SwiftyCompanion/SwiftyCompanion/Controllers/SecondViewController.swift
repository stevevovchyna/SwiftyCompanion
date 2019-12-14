//
//  SecondViewController.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 11.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation

class SecondViewController: UIViewController {
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var generalView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    let usernameLabel = myLabel()
    let emailLabel = myLabel()
    let availabilityLabel = myLabel()
    let backButton = UIButton()
    
    var userData : UserData?
    var userImage : UserImage?
    var userCoalition : Coalition?
    var projectNames : ProjectNames?
    var topInset : CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        generalView.backgroundColor = userCoalition?.additionalColor1
        
        tableView.contentInset = UIEdgeInsets(top: 300 - (topInset ?? 0), left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "LevelTableViewCell", bundle: nil), forCellReuseIdentifier: "levelCell")
        tableView.register(UINib(nibName: "GeneralDataTableViewCell", bundle: nil), forCellReuseIdentifier: "generalDataCell")
        
        if let imageData = self.userImage?.imageData {
            self.imageView.image = UIImage(data: imageData)
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        generalView.addSubview(imageView)
        
        addLabel(withLabel: usernameLabel,
                 withText: "\(userData?.username ?? "No data") - \(userData?.availableAt ?? "Unavailable")",
                 withCGRect: CGRect(x: 10, y: 265, width: 0, height: 0),
                 withColor: userCoalition!.additionalColor1,
                 toView: imageView)
        addLabel(withLabel: emailLabel,
                 withText: userData?.email ?? "No data",
                 withCGRect: CGRect(x: 10, y: 300, width: 0, height: 0),
                 withColor: userCoalition!.additionalColor1,
                 toView: imageView)

        backButton.frame = CGRect(x: 10, y: 10 + (topInset ?? 0), width: 50, height: 50)
        backButton.layer.cornerRadius = 25
        backButton.setTitle("<", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = userCoalition?.additionalColor1
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        generalView.addSubview(backButton)
        
        if let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
            backButton.frame = interfaceOrientation.isPortrait ? CGRect(x: 10, y: 10 + (topInset ?? 0), width: 50, height: 50) : CGRect(x: 10 + (topInset ?? 0), y: 10, width: 50, height: 50)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        switch UIDevice.current.orientation {
        case .portrait:
            backButton.frame = CGRect(x: 10, y: 10 + (topInset ?? 0), width: 50, height: 50)
        case .landscapeLeft, .landscapeRight:
            backButton.frame = CGRect(x: 10 + (topInset ?? 0), y: 10, width: 50, height: 50)
        default:
            backButton.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let y = yOffset > -160 ? 160 + (topInset ?? 0) : -yOffset + (topInset ?? 0)
        imageHeightConstraint.constant = y
        emailLabel.frame = CGRect(x: 10, y: y - 44, width: 0, height: 0)
        usernameLabel.frame = CGRect(x: 10, y: y - 79, width: 0, height: 0)
        usernameLabel.sizeToFit()
        emailLabel.sizeToFit()
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
        let skillsCount = (userData?.skills.count ?? 0) == 0 ? 1 : userData!.skills.count
        let projectsCount = (userData?.projects.count ?? 0) == 0 ? 1 : userData!.projects.count
        
        switch indexPath.row {
        case 0:
            return levelCell(withIndexPath: indexPath, withTableView: tableView)
        case 1:
            return generalDataCell(withIndexPath: indexPath, withTableView: tableView)
        case 2:
            return dividerCell(withName: "Skills", withIndexPath: indexPath, withTableView: tableView)
        case 3...skillsCount + 2:
            if let skills = userData?.skills, userData?.skills.count != 0 {
                return skillCell(withSkills: skills, withIndexPath: indexPath, withTableView: tableView)
            } else {
                return dividerCell(withName: "Projects", withIndexPath: indexPath, withTableView: tableView)
            }
        case skillsCount + 3:
            return dividerCell(withName: "Projects", withIndexPath: indexPath, withTableView: tableView)
        case skillsCount + 4...projectsCount + skillsCount + 3:
            return projectCell(withSkillsCount: skillsCount, withIndexPath: indexPath, withTableView: tableView)
        default:
            return dividerCell(withName: "No data", withIndexPath: indexPath, withTableView: tableView)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}

extension SecondViewController {
    
    func dividerCell(withName cellName: String, withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        levelCell.cellHeight.constant = 30
        levelCell.levelLabel.text = cellName
        levelCell.backgroundLabel.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        levelCell.levelLabel.textColor = .white
        levelCell.rightConstraint.constant = 0
        return levelCell
    }
    
    func levelCell(withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        let floatLevel = ((userData?.level ?? "0") as NSString).floatValue
        levelCell.backgroundColor = userCoalition?.mainColor
        levelCell.cellHeight.constant = 44
        levelCell.levelLabel.text = String(format: "%.2f%", floatLevel)
        levelCell.backgroundLabel.backgroundColor = userCoalition?.additionalColor1
        let rightInset = UIScreen.main.bounds.size.width - (UIScreen.main.bounds.size.width / 21) * CGFloat(floatLevel)
        levelCell.rightConstraint.constant = rightInset
        return levelCell
    }
    
    func generalDataCell(withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let generalDataCell = tableView.dequeueReusableCell(withIdentifier: "generalDataCell", for: indexPath) as! GeneralDataTableViewCell
        generalDataCell.backgroundColor = userCoalition?.additionalColor2
        generalDataCell.fullNameLabel.text = "\(userData?.firstName ?? "Somebody") \(userData?.lastName ?? "Somebody")"
        generalDataCell.phoneNumberLabel.text = userData?.phone
        generalDataCell.evaluationPointsLabel.text = userData?.evaluationPoints
        generalDataCell.gradeLabel.text = userData?.grade
        generalDataCell.walletLabel.text = userData?.wallets
        generalDataCell.poolYearLabel.text = userData?.poolYear
        return generalDataCell
    }
    
    func skillCell(withSkills skills: [Skill], withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        levelCell.levelLabel.text = "\(skills[indexPath.row - 3].skillName) - \(skills[indexPath.row - 3].skillLevel)"
        let rightInset = UIScreen.main.bounds.size.width - ((UIScreen.main.bounds.size.width / 20) * CGFloat(Double(skills[indexPath.row - 3].skillLevel) ?? 0))
        levelCell.rightConstraint.constant = rightInset
        levelCell.levelLabel.textColor = .black
        levelCell.backgroundLabel.backgroundColor = randomColor()
        levelCell.cellHeight.constant = 30
        levelCell.backgroundColor = userCoalition?.mainColor
        return levelCell
    }
    
    func projectCell(withSkillsCount skillsCount: Int, withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        if let project = userData?.projects[indexPath.row - (skillsCount + 4)] {
            let possibleParent = project.projectIsInPiscine ? "\(projectNames?.entities[project.projectParentID!] ?? "No data") " : ""
            levelCell.levelLabel.text = possibleParent + "\(project.projectName) - \(project.projectFinalMark)"
            levelCell.backgroundLabel.backgroundColor = project.projectIsValidated ? userCoalition?.additionalColor1 : userCoalition?.additionalColor3
            if project.projectFinalMark != "0", project.projectFinalMark != "-42" {
                let rightInset = UIScreen.main.bounds.size.width - ((UIScreen.main.bounds.size.width / 125) * CGFloat(Double(project.projectFinalMark) ?? 0))
                levelCell.rightConstraint.constant = rightInset
            } else {
                levelCell.rightConstraint.constant = 0
            }
        } else {
            levelCell.levelLabel.text = "No data"
            levelCell.backgroundLabel.backgroundColor = userCoalition?.mainColor
        }
        levelCell.levelLabel.textColor = .black
        levelCell.cellHeight.constant = 30
        levelCell.backgroundColor = userCoalition?.mainColor
        return levelCell
    }
    
}

extension SecondViewController {
    func addLabel(withLabel usernameLabel: UILabel, withText labelText: String, withCGRect rect: CGRect, withColor color: UIColor, toView: UIView) {
        usernameLabel.text = labelText
        usernameLabel.frame = rect
        usernameLabel.backgroundColor = color
        usernameLabel.textColor = .white
        toView.addSubview(usernameLabel)
    }

    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    func randomColor() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
    }
}
