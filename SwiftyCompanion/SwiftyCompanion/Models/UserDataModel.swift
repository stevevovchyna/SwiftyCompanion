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
    
    
    init(userID: String, token: String, handler: @escaping () -> ()) {
        coalitionName = ""
        coalitionColor = ""
        coalitionScore = ""
        mainColor = #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 0.49)
        additionalColor1 = #colorLiteral(red: 0.09411764706, green: 0.2745098039, blue: 0.0431372549, alpha: 0.72)
        additionalColor2 = #colorLiteral(red: 0.5333333333, green: 0.7019607843, blue: 0.6745098039, alpha: 0.76)
        additionalColor3 = #colorLiteral(red: 0.8078431373, green: 0.2078431373, blue: 0.4431372549, alpha: 0.7)
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
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
                    self.mainColor = #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 0.49)
                    self.additionalColor1 = #colorLiteral(red: 0.09411764706, green: 0.2745098039, blue: 0.0431372549, alpha: 0.72)
                    self.additionalColor2 = #colorLiteral(red: 0.5333333333, green: 0.7019607843, blue: 0.6745098039, alpha: 0.76)
                    self.additionalColor3 = #colorLiteral(red: 0.8078431373, green: 0.2078431373, blue: 0.4431372549, alpha: 0.7)
                case "#673ab7ff":
                    self.mainColor = #colorLiteral(red: 0.4847918309, green: 0.2755973739, blue: 0.8749479789, alpha: 0.3059246575)
                    self.additionalColor1 = #colorLiteral(red: 0.4078431373, green: 0.2941176471, blue: 0.5803921569, alpha: 0.7)
                    self.additionalColor2 = #colorLiteral(red: 0.7137254902, green: 0.7098039216, blue: 0.8274509804, alpha: 0.76)
                    self.additionalColor3 = #colorLiteral(red: 0.8745098039, green: 1, blue: 0.3254901961, alpha: 0.7)
                case "#f44336ff":
                    self.mainColor = #colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 0.7)
                    self.additionalColor1 = #colorLiteral(red: 0.6235294118, green: 0.003921568627, blue: 0.007843137255, alpha: 0.7)
                    self.additionalColor2 = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8901960784, alpha: 0.7)
                    self.additionalColor3 = #colorLiteral(red: 0, green: 0.9058823529, blue: 0.7176470588, alpha: 0.7)
                case "#00bcd4ff":
                    self.mainColor = #colorLiteral(red: 0, green: 0.737254902, blue: 0.831372549, alpha: 0.7)
                    self.additionalColor1 = #colorLiteral(red: 0.09803921569, green: 0.2666666667, blue: 0.3764705882, alpha: 0.7)
                    self.additionalColor2 = #colorLiteral(red: 0.9215686275, green: 0.9176470588, blue: 0.937254902, alpha: 0.7)
                    self.additionalColor3 = #colorLiteral(red: 0.9294117647, green: 0.3725490196, blue: 0.3882352941, alpha: 0.7)
                default:
                    self.mainColor = #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 0.49)
                    self.additionalColor1 = #colorLiteral(red: 0.09411764706, green: 0.2745098039, blue: 0.0431372549, alpha: 0.72)
                    self.additionalColor2 = #colorLiteral(red: 0.5333333333, green: 0.7019607843, blue: 0.6745098039, alpha: 0.76)
                    self.additionalColor3 = #colorLiteral(red: 0.8078431373, green: 0.2078431373, blue: 0.4431372549, alpha: 0.7)
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
    
    init(uniqueIDs: [String], token: String, handler: @escaping () -> ()) {
        let queue = OperationQueue()
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
