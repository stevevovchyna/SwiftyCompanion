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
    
    var user: User?
    var topInset : CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = user else { return }
        imageView.image = user.userImage
        tableView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: "LevelTableViewCell", bundle: nil), forCellReuseIdentifier: "levelCell")
        tableView.register(UINib(nibName: "GeneralDataTableViewCell", bundle: nil), forCellReuseIdentifier: "generalDataCell")
        setUpImageView()
        addLabel(withLabel: usernameLabel,
                 withText: "\(user.username) - \(user.availableAt)",
                 withCGRect: CGRect(x: 10, y: 221 + (topInset ?? 0), width: 0, height: 0),
                 withColor: user.colors.additionalColor1,
                 toView: imageView)
        addLabel(withLabel: emailLabel,
                 withText: user.email,
                 withCGRect: CGRect(x: 10, y: 256 + (topInset ?? 0), width: 0, height: 0),
                 withColor: user.colors.additionalColor1,
                 toView: imageView)
        addBackButton(with: user.colors.additionalColor1)
        addParallaxToView(vw: backButton)
        addParallaxToView(vw: tableView)
        addParallaxToView(vw: usernameLabel)
        addParallaxToView(vw: emailLabel)
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
    
    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let user = user else { return 0 }
        return 4 + (user.projects.count) + (user.skills.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user = user else { return dividerCell(withName: "No data", withIndexPath: indexPath, withTableView: tableView) }
        let skillsCount = (user.skills.count) == 0 ? 1 : user.skills.count
        let projectsCount = (user.projects.count) == 0 ? 1 : user.projects.count
        
        switch indexPath.row {
        case 0:
            return levelCell(withIndexPath: indexPath, withTableView: tableView, for: user)
        case 1:
            return generalDataCell(withIndexPath: indexPath, withTableView: tableView, for: user)
        case 2:
            return dividerCell(withName: "Skills", withIndexPath: indexPath, withTableView: tableView)
        case 3...skillsCount + 2:
            if user.skills.count != 0 {
                return skillCell(withSkills: user.skills, withIndexPath: indexPath, withTableView: tableView, for: user)
            } else {
                return dividerCell(withName: "Projects", withIndexPath: indexPath, withTableView: tableView)
            }
        case skillsCount + 3:
            return dividerCell(withName: "Projects", withIndexPath: indexPath, withTableView: tableView)
        case skillsCount + 4...projectsCount + skillsCount + 3:
            return projectCell(withSkillsCount: skillsCount, withIndexPath: indexPath, withTableView: tableView, for: user)
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
    
    private func levelCell(withIndexPath indexPath: IndexPath, withTableView tableView: UITableView, for user: User) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        cellDimentionalSetUp(forCell: levelCell, withMainColor: user.colors.mainColor, withAddColor: user.colors.additionalColor1, withYInsets: 10, withCellHeigth: 44)
        let cellWidth = calculateCellWidth(forCell: levelCell)
        let floatLevel = ((user.level) as NSString).floatValue
        levelCell.levelLabel.text = String(format: "%.2f%", floatLevel)
        levelCell.levelLabel.textColor = .black
        let rightInset = cellWidth - (cellWidth / 21) * CGFloat(floatLevel)
        levelCell.rightConstraint.constant = rightInset
        return levelCell
    }
    
    private func dividerCell(withName cellName: String, withIndexPath indexPath: IndexPath, withTableView tableView: UITableView) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        cellDimentionalSetUp(forCell: levelCell, withMainColor: .clear, withAddColor: .black, withYInsets: 10, withCellHeigth: 30)
        levelCell.levelLabel.text = cellName
        levelCell.levelLabel.textColor = .white
        levelCell.rightConstraint.constant = 0
        return levelCell
    }
    
    private func generalDataCell(withIndexPath indexPath: IndexPath, withTableView tableView: UITableView, for user: User) -> UITableViewCell {
        let gCell = tableView.dequeueReusableCell(withIdentifier: "generalDataCell", for: indexPath) as! GeneralDataTableViewCell
        gCell.fullNameLabel.text = "\(user.firstName) \(user.lastName)"
        gCell.phoneNumberLabel.text = user.phone
        gCell.evaluationPointsLabel.text = user.evaluationPoints
        gCell.gradeLabel.text = user.grade
        gCell.walletLabel.text = user.wallets
        gCell.poolYearLabel.text = user.poolYear

        gCell.mainView.layer.cornerRadius = 10
        gCell.backgroundColor = .clear
        gCell.mainView.backgroundColor = user.colors.additionalColor2

        gCell.leftConstraint.constant = 5
        gCell.rightConstraint.constant = 5
        gCell.topConstraint.constant = 5
        gCell.bottomConstraint.constant = 5

        gCell.layer.shadowColor = UIColor.black.cgColor
        gCell.layer.shadowRadius = 2.0
        gCell.layer.shadowOpacity = 0.5
        gCell.layer.shadowOffset = CGSize(width: 0, height: 2)
        return gCell
    }
    
    private func skillCell(withSkills skills: [Skill], withIndexPath indexPath: IndexPath, withTableView tableView: UITableView, for user: User) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        cellDimentionalSetUp(forCell: levelCell, withMainColor: user.colors.additionalColor2, withAddColor: user.colors.mainColor, withYInsets: 2, withCellHeigth: 44)
        let cellWidth = calculateCellWidth(forCell: levelCell)
        let skillLevel = (skills[indexPath.row - 3].skillLevel as NSString).floatValue
        levelCell.levelLabel.text = "\(skills[indexPath.row - 3].skillName) - \(String(format: "%.2f", skillLevel))"
        levelCell.levelLabel.textColor = .black
        let rightInset = cellWidth - ((cellWidth / 20) * CGFloat(skillLevel))
        levelCell.rightConstraint.constant = rightInset
        return levelCell
    }
    
    private func projectCell(withSkillsCount skillsCount: Int, withIndexPath indexPath: IndexPath, withTableView tableView: UITableView, for user: User) -> UITableViewCell {
        let levelCell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! LevelTableViewCell
        cellDimentionalSetUp(forCell: levelCell, withMainColor: user.colors.mainColor, withAddColor: user.colors.mainColor, withYInsets: 2, withCellHeigth: 44)
        let cellWidth = calculateCellWidth(forCell: levelCell)
        let project = user.projects[indexPath.row - (skillsCount + 4)]
        levelCell.levelLabel.text = "\(project.projectSlug) - \(project.projectFinalMark)"
        levelCell.levelLabel.textColor = .black
        levelCell.backgroundLabel.backgroundColor = project.projectIsValidated ? user.colors.additionalColor1 : user.colors.additionalColor3
        if project.projectFinalMark != "0", project.projectFinalMark != "-42" {
            let rightInset = cellWidth - ((cellWidth / 125) * CGFloat(Double(project.projectFinalMark) ?? 0))
            levelCell.rightConstraint.constant = rightInset
        } else {
            levelCell.rightConstraint.constant = 0
        }
        return levelCell
    }
}

extension SecondViewController {
    
    private func setUpImageView() {
        imageView.layer.cornerRadius = 20
        imageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 3.0
        imageView.layer.shadowOpacity = 0.7
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
    }
    
    private func addBackButton(with color: UIColor) {
        backButton.frame = CGRect(x: 10, y: 10 + (topInset ?? 0), width: 50, height: 50)
        backButton.layer.cornerRadius = 25
        backButton.setTitle("<", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = color
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        generalView.addSubview(backButton)
    }
    
    private func addLabel(withLabel usernameLabel: UILabel, withText labelText: String, withCGRect rect: CGRect, withColor color: UIColor, toView: UIView) {
        usernameLabel.text = labelText
        usernameLabel.frame = rect
        usernameLabel.backgroundColor = color
        usernameLabel.textColor = .white
        usernameLabel.layer.shadowColor = UIColor.black.cgColor
        usernameLabel.layer.shadowRadius = 3.0
        usernameLabel.layer.shadowOpacity = 0.7
        usernameLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        toView.addSubview(usernameLabel)
        usernameLabel.sizeToFit()
    }
    
    private func shadesAnimation(forView levelCell: LevelTableViewCell) {
        UIView.animate(withDuration: 2) {
            levelCell.veryBackgroundLabel.layer.shadowColor = UIColor.black.cgColor
            levelCell.veryBackgroundLabel.layer.shadowRadius = 2.0
            levelCell.veryBackgroundLabel.layer.shadowOpacity = 0.5
            levelCell.veryBackgroundLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
    }
    
    private func cellDimentionalSetUp(forCell levelCell: LevelTableViewCell, withMainColor mainColor: UIColor, withAddColor addColor: UIColor, withYInsets YInsets: CGFloat, withCellHeigth cellHeight: CGFloat) {
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
    
    private func calculateCellWidth(forCell levelCell: LevelTableViewCell) -> CGFloat {
        let tableInsets = tableViewLeftConstraint.constant + (tableViewRightConstraint.constant < 0 ? -tableViewRightConstraint.constant : tableViewRightConstraint.constant)
        let cellInsets = levelCell.rightInsetConstraint.constant - levelCell.leftConstraint.constant
        let width = tableView.frame.size.width - cellInsets - tableInsets
        return width
    }

    
}
