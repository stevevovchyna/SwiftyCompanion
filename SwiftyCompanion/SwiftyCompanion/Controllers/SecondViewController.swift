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
    
    @IBOutlet weak var tableViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeftConstraint: NSLayoutConstraint!
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
        
        generalView.backgroundColor = .white
        
        tableView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .white
        tableView.register(UINib(nibName: "LevelTableViewCell", bundle: nil), forCellReuseIdentifier: "levelCell")
        tableView.register(UINib(nibName: "GeneralDataTableViewCell", bundle: nil), forCellReuseIdentifier: "generalDataCell")
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableViewLeftConstraint.constant = 10
        tableViewRightConstraint.constant = -10
        
        if let imageData = self.userImage?.imageData {
            self.imageView.image = UIImage(data: imageData)
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 3.0
        imageView.layer.shadowOpacity = 0.7
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        
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
        self.tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let animation = Animations.slideIn(duration: 0.5, delay: 0)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
    }
}

extension SecondViewController {
    
    func levelCell(withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        cellDimentionalSetUp(forCell: levelCell, withMainColor: userCoalition?.mainColor, withAddColor: userCoalition?.additionalColor1, withYInsets: 10, withCellHeigth: 44)
        let cellWidth = calculateCellWidth(forCell: levelCell)
        let floatLevel = ((userData?.level ?? "0") as NSString).floatValue
        levelCell.levelLabel.text = String(format: "%.2f%", floatLevel)
        levelCell.levelLabel.textColor = .black
        let rightInset = cellWidth - (cellWidth / 21) * CGFloat(floatLevel)
        levelCell.rightConstraint.constant = rightInset
        return levelCell
    }
    
    func dividerCell(withName cellName: String, withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        cellDimentionalSetUp(forCell: levelCell, withMainColor: .clear, withAddColor: .black, withYInsets: 10, withCellHeigth: 30)
        levelCell.levelLabel.text = cellName
        levelCell.levelLabel.textColor = .white
        levelCell.rightConstraint.constant = 0
        return levelCell
    }
    
    func generalDataCell(withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let generalDataCell = tableView.dequeueReusableCell(withIdentifier: "generalDataCell", for: indexPath) as! GeneralDataTableViewCell
        generalDataCell.fullNameLabel.text = "\(userData?.firstName ?? "Somebody") \(userData?.lastName ?? "Somebody")" 
        generalDataCell.phoneNumberLabel.text = userData?.phone
        generalDataCell.evaluationPointsLabel.text = userData?.evaluationPoints
        generalDataCell.gradeLabel.text = userData?.grade
        generalDataCell.walletLabel.text = userData?.wallets
        generalDataCell.poolYearLabel.text = userData?.poolYear
        generalDataCell.mainView.layer.cornerRadius = 10
        generalDataCell.backgroundColor = .clear
        generalDataCell.mainView.backgroundColor = userCoalition?.additionalColor2
        generalDataCell.leftConstraint.constant = 5
        generalDataCell.rightConstraint.constant = 5
        generalDataCell.topConstraint.constant = 5
        generalDataCell.bottomConstraint.constant = 5
        generalDataCell.layer.shadowColor = UIColor.black.cgColor
        generalDataCell.layer.shadowRadius = 2.0
        generalDataCell.layer.shadowOpacity = 0.5
        generalDataCell.layer.shadowOffset = CGSize(width: 0, height: 2)
        return generalDataCell
    }
    
    func skillCell(withSkills skills: [Skill], withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        cellDimentionalSetUp(forCell: levelCell, withMainColor: userCoalition?.additionalColor2, withAddColor: userCoalition?.mainColor, withYInsets: 2, withCellHeigth: 44)
        let cellWidth = calculateCellWidth(forCell: levelCell)
        let skillLevel = (skills[indexPath.row - 3].skillLevel as NSString).floatValue
        levelCell.levelLabel.text = "\(skills[indexPath.row - 3].skillName) - \(String(format: "%.2f", skillLevel))"
        levelCell.levelLabel.textColor = .black
        let rightInset = cellWidth - ((cellWidth / 20) * CGFloat(skillLevel))
        levelCell.rightConstraint.constant = rightInset
        return levelCell
    }
    
    func projectCell(withSkillsCount skillsCount: Int, withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        cellDimentionalSetUp(forCell: levelCell, withMainColor: userCoalition?.mainColor, withAddColor: userCoalition?.mainColor, withYInsets: 2, withCellHeigth: 44)
        let cellWidth = calculateCellWidth(forCell: levelCell)
        if let project = userData?.projects[indexPath.row - (skillsCount + 4)] {
            let possibleParent = project.projectIsInPiscine ? "\(projectNames?.entities[project.projectParentID!] ?? "No data") " : ""
            levelCell.levelLabel.text = possibleParent + "\(project.projectName) - \(project.projectFinalMark)"
            levelCell.levelLabel.textColor = .black
            levelCell.backgroundLabel.backgroundColor = project.projectIsValidated ? userCoalition?.additionalColor1 : userCoalition?.additionalColor3
            if project.projectFinalMark != "0", project.projectFinalMark != "-42" {
                let rightInset = cellWidth - ((cellWidth / 125) * CGFloat(Double(project.projectFinalMark) ?? 0))
                levelCell.rightConstraint.constant = rightInset
            } else {
                levelCell.rightConstraint.constant = 0
            }
        } else {
            levelCell.levelLabel.text = "No data"
            levelCell.backgroundLabel.backgroundColor = userCoalition?.mainColor
        }
        return levelCell
    }
}

extension SecondViewController {
    func addLabel(withLabel usernameLabel: UILabel, withText labelText: String, withCGRect rect: CGRect, withColor color: UIColor, toView: UIView) {
        usernameLabel.text = labelText
        usernameLabel.frame = rect
        usernameLabel.backgroundColor = color
        usernameLabel.textColor = .white
        usernameLabel.layer.shadowColor = UIColor.black.cgColor
        usernameLabel.layer.shadowRadius = 3.0
        usernameLabel.layer.shadowOpacity = 0.7
        usernameLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        toView.addSubview(usernameLabel)
    }
    
    func shadesAnimation(forView levelCell: LevelTableViewCell) {
        UIView.animate(withDuration: 2) {
            levelCell.veryBackgroundLabel.layer.shadowColor = UIColor.black.cgColor
            levelCell.veryBackgroundLabel.layer.shadowRadius = 2.0
            levelCell.veryBackgroundLabel.layer.shadowOpacity = 0.5
            levelCell.veryBackgroundLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
    }
    
    func cellDimentionalSetUp(forCell levelCell: LevelTableViewCell, withMainColor mainColor: UIColor?, withAddColor addColor: UIColor?, withYInsets YInsets: CGFloat, withCellHeigth cellHeight: CGFloat) {
        levelCell.topConstraint.constant = YInsets
        levelCell.bottomConstraint.constant = YInsets
        levelCell.rightInsetConstraint.constant = 5
        levelCell.leftConstraint.constant = 5
        levelCell.layer.cornerRadius = 10
        levelCell.backgroundLabel.layer.cornerRadius = 10
        levelCell.veryBackgroundLabel.layer.cornerRadius = 10
        levelCell.veryBackgroundLabel.backgroundColor = mainColor
        levelCell.backgroundLabel.backgroundColor = addColor
        levelCell.backgroundColor = .clear
        levelCell.cellHeight.constant = cellHeight
        levelCell.backgroundHeight.constant = cellHeight
        shadesAnimation(forView: levelCell)
    }
    
    func calculateCellWidth(forCell levelCell: LevelTableViewCell) -> CGFloat {
        let tableInsets = tableViewLeftConstraint.constant + (tableViewRightConstraint.constant < 0 ? -tableViewRightConstraint.constant : tableViewRightConstraint.constant)
        let cellInsets = levelCell.rightInsetConstraint.constant - levelCell.leftConstraint.constant
        let width = tableView.frame.size.width - cellInsets - tableInsets
        return width
    }

    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    func randomColor() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
    }
}

extension UITableView {
    func isLastVisibleCell(at indexPath: IndexPath) -> Bool {
        guard let lastIndexPath = indexPathsForVisibleRows?.last else { return false }
        return lastIndexPath == indexPath
    }
}
