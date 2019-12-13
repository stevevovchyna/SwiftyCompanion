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

class DownloadOperation : Operation {
    
    private var task : URLSessionDataTask!
    
    enum OperationState : Int {
        case ready
        case executing
        case finished
    }
    
    private var state : OperationState = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }
  
    init(session: URLSession, dataTaskURLRequest: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        super.init()
        
        task = session.dataTask(with: dataTaskURLRequest, completionHandler: { [weak self] (data, response, error) in

            if let completionHandler = completionHandler {
                completionHandler(data, response, error)
            }
            self?.state = .finished
            print("done!!!")
        })
    }

    override func start() {
        if self.isCancelled {
            state = .finished
            return
        }
        state = .executing
        self.task.resume()
    }

    override func cancel() {
        super.cancel()
        self.task.cancel()
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

class UserData {
    
    let token : String
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
    
    init(userData : JSON, APIToken : String) {
        token = APIToken
        username = userData["login"].stringValue
        email = userData["email"].stringValue
        availableAt = userData["location"].stringValue
        if availableAt == "" {
            availableAt = "Unavailable"
        }
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
        projects = []
        for project in userData["projects_users"] {
            if project.1["cursus_ids"][0].stringValue == "1", project.1["validated?"].stringValue != "" {
                projects.append(Project(project: project.1))
            }
        }
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
    
    func description() {
        print(username, email, availableAt, level, phone, firstName, lastName, wallets, evaluationPoints, grade, poolYear, skills, projects)
    }
}
