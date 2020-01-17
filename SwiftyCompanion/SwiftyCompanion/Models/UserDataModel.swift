//
//  UserDataModel.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 12.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct User {
    let username : String
    let email : String
    var availableAt : String
    let level : String
    let phone : String
    let firstName : String
    let lastName : String
    let wallets : String
    let evaluationPoints : String
    let grade : String
    let poolYear : String
    let userImageURL: String
    var skills : [Skill] = []
    var projects : [Project] = []
    
    var userImage : UIImage?
    
    let colors : Colors
    
    init(_ userData: NSDictionary, _ image: UIImage, _ colors: Colors) {
        userImage = image
        self.colors = colors
        username = userData["login"] as! String
        email = userData["email"] as! String
        availableAt = (userData["location"] as? NSNull) != nil ? "Unavailable" : userData["location"] as! String
        let cursus = userData["cursus_users"] as! NSArray
        let cursusZero = cursus[0] as! NSDictionary
        level = String(cursusZero["level"] as! Double)
        phone = userData["phone"] as! String
        firstName = userData["first_name"] as! String
        lastName = userData["last_name"] as! String
        wallets = String(userData["wallet"] as! Double)
        evaluationPoints = String(userData["correction_point"] as! Double)
        grade = cursusZero["grade"] as! String
        poolYear = userData["pool_year"] as? String ?? "No data"
        userImageURL = userData["image_url"] as! String
        for skill in cursusZero["skills"] as! NSArray {
            skills.append(Skill(skill: skill as! NSDictionary))
        }
        skills.sort { $0.skillName < $1.skillName }
        for project in userData["projects_users"] as! NSArray {
            let projectIDs = ((project as! NSDictionary)["cursus_ids"] as! NSArray)[0] as! Double
            let status = (project as! NSDictionary)["status"] as! String
            if projectIDs == 1, status == "finished" {
                projects.append(Project(project: project as! NSDictionary))
            }
        }
        projects.sort { $0.projectName < $1.projectName }
    }
}

struct Colors {
    var mainColor : UIColor
    var additionalColor1: UIColor
    var additionalColor2: UIColor
    var additionalColor3: UIColor
    
    init(_ color1: UIColor, _ color2: UIColor, _ color3: UIColor, _ color4: UIColor) {
        mainColor = color1
        additionalColor1 = color2
        additionalColor2 = color3
        additionalColor3 = color4
    }
}

struct Project {
    let projectName : String
    let projectSlug : String
    let projectStatus : String
    let projectIsValidated : Bool
    let projectFinalMark : String
    
    init(project : NSDictionary) {
        let proj = project["project"] as! NSDictionary
        projectName = proj["name"] as! String
        projectSlug = (proj["slug"] as! String).camelCased(with: "-").camelCaseToWords().capitalized
        projectStatus = project["status"] as! String
        projectIsValidated = project["validated?"] as! Bool
        projectFinalMark = String(project["final_mark"] as! Int)
    }
}

struct Skill {
    let skillName : String
    let skillLevel : String
    
    init(skill : NSDictionary) {
        skillName = skill["name"] as! String
        skillLevel = String(skill["level"] as! Double)
    }
}
