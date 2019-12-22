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

class UserData {
    
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
    var skills : [Skill]
    var projects : [Project]
    
    var uniqueIDs : [String]
    var userImageURL : String
    
    init(userData : JSON) {
        username = userData["login"].stringValue
        email = userData["email"].stringValue
        availableAt = userData["location"].stringValue == "" ?  "Unavailable" : userData["location"].stringValue
        level = userData["cursus_users"][0]["level"].stringValue
        phone = userData["phone"].stringValue
        firstName = userData["first_name"].stringValue
        lastName = userData["last_name"].stringValue
        wallets = userData["wallet"].stringValue
        evaluationPoints = userData["correction_point"].stringValue
        grade = userData["cursus_users"][0]["grade"].stringValue
        poolYear = userData["pool_year"].stringValue
        userImageURL = userData["image_url"].stringValue
        skills = []
        for skill in userData["cursus_users"][0]["skills"] {
            skills.append(Skill(skill: skill.1))
        }
        skills.sort { $0.skillName < $1.skillName }
        projects = []
        for project in userData["projects_users"] {
            if project.1["cursus_ids"][0].stringValue == "1", project.1["validated?"].stringValue != "" {
                projects.append(Project(project: project.1))
            }
        }
        projects.sort { $0.projectName < $1.projectName }
        uniqueIDs = UserData.getRushIDs(projects: projects)
    }
    
    static func getRushIDs(projects: [Project]) -> [String] {
        var IDs : [String] = []
        for id in projects {
            if let i = id.projectParentID {
                IDs.append(i)
            }
        }
        let uniqueIDs = Array(Set(IDs))
        return uniqueIDs
    }
}

class Coalition {
    var coalitionName : String
    var coalitionScore : String
    var coalitionColor : String
    var mainColor : UIColor
    var additionalColor1: UIColor
    var additionalColor2: UIColor
    var additionalColor3: UIColor
    
    
    init(userID: String, handler: @escaping () -> ()) {
        coalitionName = ""
        coalitionColor = ""
        coalitionScore = ""
        mainColor = #colorLiteral(red: 0.8666666667, green: 0.9176470588, blue: 0.9333333333, alpha: 0.7272945205)
        additionalColor1 = #colorLiteral(red: 0.1333333333, green: 0.6980392157, blue: 0.9176470588, alpha: 0.7272945205)
        additionalColor2 = #colorLiteral(red: 0.5490196078, green: 0.6745098039, blue: 0.8156862745, alpha: 0.7272945205)
        additionalColor3 = #colorLiteral(red: 0.8352941176, green: 0.3882352941, blue: 0.3529411765, alpha: 0.7272945205)
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let token = KeychainManager().retrieveToken(for: "access_token")!
        let urlString = "https://api.intra.42.fr/v2/users/\(userID)/coalitions"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let operation = DownloadOperation(session: URLSession.shared, dataTaskURLRequest: request, completionHandler: { (data, response, error) in
            if let data = data {
                self.coalitionName = JSON(data)[0]["name"].stringValue
                self.coalitionScore = JSON(data)[0]["score"].stringValue
                self.coalitionColor = JSON(data)[0]["color"].stringValue + "ff"
                
                switch self.coalitionColor {
                case "#4caf50ff":
                    self.mainColor = #colorLiteral(red: 0.7058823529, green: 0.8392156863, blue: 0.6784313725, alpha: 0.7714640411)
                    self.additionalColor1 = #colorLiteral(red: 0.3647058824, green: 0.5529411765, blue: 0.3647058824, alpha: 0.72)
                    self.additionalColor2 = #colorLiteral(red: 0.5333333333, green: 0.7019607843, blue: 0.6745098039, alpha: 0.76)
                    self.additionalColor3 = #colorLiteral(red: 0.6470588235, green: 0.07450980392, blue: 0.1137254902, alpha: 0.7)
                case "#673ab7ff":
                    self.mainColor = #colorLiteral(red: 0.6784313725, green: 0.8235294118, blue: 0.9725490196, alpha: 0.3059246575)
                    self.additionalColor1 = #colorLiteral(red: 0.7215686275, green: 0.568627451, blue: 0.7568627451, alpha: 0.7)
                    self.additionalColor2 = #colorLiteral(red: 0.5529411765, green: 0.1764705882, blue: 0.4, alpha: 0.76)
                    self.additionalColor3 = #colorLiteral(red: 0.6784313725, green: 0.8235294118, blue: 0.9725490196, alpha: 0.7)
                case "#f44336ff":
                    self.mainColor = #colorLiteral(red: 1, green: 0.5450980392, blue: 0.462745098, alpha: 0.7)
                    self.additionalColor1 = #colorLiteral(red: 1, green: 0.1882352941, blue: 0.1921568627, alpha: 0.7)
                    self.additionalColor2 = #colorLiteral(red: 0.5568627451, green: 0, blue: 0.06274509804, alpha: 0.7)
                    self.additionalColor3 = #colorLiteral(red: 0.5764705882, green: 0.6, blue: 0.6, alpha: 0.7)
                case "#00bcd4ff":
                    self.mainColor = #colorLiteral(red: 0.8666666667, green: 0.9176470588, blue: 0.9333333333, alpha: 0.7272945205)
                    self.additionalColor1 = #colorLiteral(red: 0.1333333333, green: 0.6980392157, blue: 0.9176470588, alpha: 0.7272945205)
                    self.additionalColor2 = #colorLiteral(red: 0.5490196078, green: 0.6745098039, blue: 0.8156862745, alpha: 0.7272945205)
                    self.additionalColor3 = #colorLiteral(red: 0.8352941176, green: 0.3882352941, blue: 0.3529411765, alpha: 0.7272945205)
                default:
                    self.mainColor = #colorLiteral(red: 0.8666666667, green: 0.9176470588, blue: 0.9333333333, alpha: 0.7272945205)
                    self.additionalColor1 = #colorLiteral(red: 0.1333333333, green: 0.6980392157, blue: 0.9176470588, alpha: 0.7272945205)
                    self.additionalColor2 = #colorLiteral(red: 0.5490196078, green: 0.6745098039, blue: 0.8156862745, alpha: 0.7272945205)
                    self.additionalColor3 = #colorLiteral(red: 0.8352941176, green: 0.3882352941, blue: 0.3529411765, alpha: 0.7272945205)
                }
            }
            handler()
        })
        queue.addOperation(operation)
    }
}

class Project {
    let projectName : String
    let projectStatus : String
    let projectIsValidated : Bool
    let projectFinalMark : String
    var projectParentID : String?
    var projectIsInPiscine : Bool
    var projectParentName : String
    
    init(project : JSON) {
        projectName = project["project"]["name"].stringValue
        projectStatus = project["status"].stringValue
        projectIsValidated = project["validated?"].boolValue
        projectFinalMark = project["final_mark"].stringValue
        projectIsInPiscine = false
        projectParentName = "No data"
        if project["project"]["parent_id"].stringValue != "" {
            projectParentID = project["project"]["parent_id"].stringValue
            projectIsInPiscine = true
        }
    }
}

class Skill {
    let skillName : String
    let skillLevel : String
    
    init(skill : JSON) {
        skillName = skill["name"].stringValue
        skillLevel = skill["level"].stringValue
    }
}

class UserImage {
    var imageData : Data

    init(imageUrl : String, handler: @escaping () -> ()) {
        imageData = Data()
        Alamofire.request(imageUrl).responseData { response in
            if response.error == nil {
                if let data = response.data {
                    self.imageData = data
                    handler()
                }
            }
        }
    }
}

class ProjectNames {
    var entities: [String: String]
    
    init(uniqueIDs: [String], handler: @escaping () -> ()) {
        let queue = OperationQueue()
        let token = KeychainManager().retrieveToken(for: "access_token")!
        queue.maxConcurrentOperationCount = 1
        entities = [:]
        for id in uniqueIDs {
            let urlString = "https://api.intra.42.fr/v2/projects/" + id
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            let operation = DownloadOperation(session: URLSession.shared, dataTaskURLRequest: request, completionHandler: { (data, response, error) in
                if let data = data {
                    self.entities[id] = JSON(data)["name"].stringValue
                }
            })
            queue.addOperation(operation)
        }
        handler()
    }
}
