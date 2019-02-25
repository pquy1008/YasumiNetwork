//
//  YasumiService.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 1/25/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class YasumiService: NSObject {
    
    static let shared = YasumiService()
    
    func apiPost(path: String, options: [String: String], success : @escaping (_ result: JSON) -> Void, error: @escaping (Error) -> Void) {
        let endpoint = "\(Yasumi.apiBaseUri)\(path)"

        // Add header
        let header: HTTPHeaders = [
            "user-email":   (Yasumi.session?.email)!,
        ]

        print("ENDPOINT: \(endpoint)")
        Alamofire.request(endpoint, method: HTTPMethod.post, parameters: options, encoding: URLEncoding.default, headers: header)
            .responseJSON { response in
                guard let object = response.result.value else {
                    error(response.result.error!)
                    return
                }

                let json = JSON(object)
                
                if response.response?.statusCode == 400 {
                    // Bad request
                    
                    let errStr = json["error"]["message"].rawValue
                    let err = NSError(domain: Yasumi.apiBaseUri, code: (json["error"]["code"].rawValue) as? Int ?? 00, userInfo: [NSLocalizedDescriptionKey: errStr])
                    error(err)
                    
                    return
                } else if response.response?.statusCode == 401 {
                    // Unauthenticate
                    let err = NSError(domain: Yasumi.apiBaseUri, code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
                    error(err)
                    return
                } else if response.response?.statusCode != 200 {
                    // Unexpected error
                    let err = NSError(domain: Yasumi.apiBaseUri, code: response.response?.statusCode ?? 00, userInfo: nil)
                    error(err)
                    return
                }
                
                // Nice
                success(json)
        }
    }
    
    func apiGet(path: String, options: [String: String], success : @escaping (_ result: JSON) -> Void, error: @escaping (Error) -> Void) {
        var endpoint = "\(Yasumi.apiBaseUri)\(path)"
        
        // Add paramester
        if options.count > 0 {
            endpoint = endpoint + "?"
            
            for (k, v) in options {
                let escapedString = v.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
                endpoint += "\(k)=\(escapedString!)&"
            }
        }
        
        // Add header
        let header: HTTPHeaders = [
            "user-email":   (Yasumi.session?.email)!,
        ]

        print("ENDPOINT: \(endpoint)")
        Alamofire.request(endpoint, method: .get, parameters: options, encoding: URLEncoding.default, headers: header)
            .responseJSON { response in
                guard let object = response.result.value else {
                    error(response.result.error!)
                    return
                }
                
                let json = JSON(object)
                
                if response.response?.statusCode == 400 {
                    // Bad request
                    
                    let errStr = json["error"]["message"].rawValue
                    let err = NSError(domain: Yasumi.apiBaseUri, code: (json["error"]["code"].rawValue) as? Int ?? 00, userInfo: [NSLocalizedDescriptionKey: errStr])
                    error(err)
                    
                    return
                } else if response.response?.statusCode == 401 {
                    // Unauthenticate
                    let err = NSError(domain: Yasumi.apiBaseUri, code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
                    error(err)
                    return
                } else if response.response?.statusCode != 200 {
                    // Unexpected error
                    let err = NSError(domain: Yasumi.apiBaseUri, code: response.response?.statusCode ?? 00, userInfo: nil)
                    error(err)
                    return
                }
                
                // Nice
                success(json)
        }
    }
    
    func apiUpdateProfile(options: [String:String], success : @escaping ()  -> Void) {
        apiPost(path: "/chatwork/api/editProfile", options: options, success: { (res) in
            success()
        }) { (err) in
            print(err)
        }
    }
    
    func apiGetNotification(options: [String:String], success : @escaping ([Feed])  -> Void) {
        apiGet(path: "/chatwork/api/notification", options: options, success: { (res) in
            var feeds = [Feed]()
            
            res.forEach { (_, json) in
                let feed = Feed()
                
                feed.id =       json["id"].string!
                feed.userId =   json["user_id"].string!
                feed.start =    json["start"].string ?? nil
                feed.end =      json["end"].string ?? nil
                feed.date =     json["date"].string ?? nil
                feed.createAt = json["create_at"].string!
                feed.reason =   json["reason"].string!
                feed.emotion =  json["emotion"].string!
                feed.status =   json["status"].string ?? nil
                feed.time =     String(json["time"].float!)
                feed.userName = json["user_name"].string ?? nil
                feed.info =     json["info"].string!
                
                let user = User()
                user.name =     json["author"]["name"].string ?? nil
                user.avatar =   json["author"]["avatar"].string ?? nil
                feed.author = user
                
                feeds.append(feed)
            }
            
            success(feeds)            
        }) { (err) in
            print(err)
        }
    }
    
    func apiGetProfile(success : @escaping (_ result: User) -> Void) {
        apiGet(path: "/chatwork/api/viewProfile", options: [String:String](), success: { (res) in

            let user = User()
            user.id = res["id"].string!
            user.name = res["name"].string ?? "-"
            user.email = res["email"].string!
            user.dob = res["birthday"].string ?? "-"
            user.country = res["country"].string ?? "-"
            user.address = res["address"].string ?? "-"
            user.quote = res["description"].string ?? "-"
            user.avatar = res["avatar"].string ?? "-"
            user.dol = res["day_off_left"].string ?? "-"
            
            switch res["role"].string {
            case "USER":
                user.role = .user
            case "MANAGER":
                user.role = .manager
            case "ADMIN":
                user.role = .admin
            default:
                user.role = .user
            }
            
            success(user)
        }) { (err) in
            print(err)
        }
    }
    
    func apiGetHistory(options: [String: String], success : @escaping (_ yasumi: [Feed], _ leave: [Feed]) -> Void) {
        apiPost(path: "/chatwork/api/viewHistory", options: options, success: { (res) in
            
            var yasumis = [Feed]()
            var leaves = [Feed]()
            
            let yasumiJson = res["Off"].array
            let leaveJson = res["Leave"].array
            
            yasumiJson?.forEach({ (json) in
                let feed = Feed()
                
                feed.id =       json["id"].string!
                feed.userId =   json["user_id"].string!
                feed.start =    json["start"].string ?? nil
                feed.end =      json["end"].string ?? nil
                feed.date =     json["date"].string ?? nil
                feed.createAt = json["create_at"].string!
                feed.reason =   json["reason"].string!
                feed.emotion =  json["emotion"].string!
                feed.status =   json["status"].string ?? nil
                feed.time =     String(json["time"].float!)
                feed.userName = json["user_name"].string ?? nil
                
                let user = User()
                user.name =     json["author"]["name"].string ?? nil
                user.avatar =   json["author"]["avatar"].string ?? nil
                feed.author = user
                
                yasumis.append(feed)
            })
            
            leaveJson?.forEach({ (json) in
                let feed = Feed()
                
                feed.id =       json["id"].string!
                feed.userId =   json["user_id"].string!
                feed.start =    json["start"].string ?? nil
                feed.end =      json["end"].string ?? nil
                feed.date =     json["date"].string ?? nil
                feed.createAt = json["create_at"].string!
                feed.reason =   json["reason"].string!
                feed.emotion =  json["emotion"].string!
                feed.status =   json["status"].string ?? nil
                feed.time =     String(json["time"].float!)
                feed.userName = json["user_name"].string ?? nil
                
                let user = User()
                user.name =     json["author"]["name"].string ?? nil
                user.avatar =   json["author"]["avatar"].string ?? nil
                feed.author = user
                
                leaves.append(feed)
            })
            
            success(yasumis, leaves)
            
        }) { (err) in
            print(err)
        }
    }
    
    func apiGetComment(isOff: Bool, options: [String: String], success : @escaping (_ result: [Comment]) -> Void) {
        
        var path = "/chatwork/api/viewLeaveDetail"
        if isOff {
            path = "/chatwork/api/viewOffDetail"
        }
        
        apiPost(path: path, options: options, success: { (res) in
            var cmts = [Comment]()
            
            let cmtJson = res["Comment"].array
            
            cmtJson!.forEach { (json) in
                let c = Comment()
                
                c.id = "xxx"
                c.avatar = json["User"]["avatar"].string ?? "-"
                c.name = json["User"]["name"].string ?? "-"
                c.msg = json["Comment"]["comment"].string ?? "-"
                
                cmts.append(c)
            }
            
            success(cmts)
        }) { (err) in
            print(err)
        }
    }
    
    func apiPostComment(options: [String: String], success : @escaping () -> Void, error : @escaping () -> Void) {
        apiPost(path: "/chatwork/api/addComment", options: options, success: { (res) in
            // Do nothing
            success()
        }) { (err) in
            print("error")
            error()
        }
    }
        
    func apiGetFeed(success : @escaping (_ result: [Feed]) -> Void) {
        apiGet(path: "/chatwork/api/home", options: [String:String](), success: { (res) in
            var feeds = [Feed]()

            res.forEach { (_, json) in
                let feed = Feed()
                
                feed.id =       json["id"].string!
                feed.userId =   json["user_id"].string!
                feed.start =    json["start"].string ?? nil
                feed.end =      json["end"].string ?? nil
                feed.date =     json["date"].string ?? nil
                feed.createAt = json["create_at"].string!
                feed.reason =   json["reason"].string!
                feed.emotion =  json["emotion"].string!
                feed.status =   json["status"].string ?? nil
                feed.time =     String(json["time"].float!)
                feed.userName = json["user_name"].string ?? nil
                feed.info =     json["info"].string!
                
                let user = User()
                user.name =     json["author"]["name"].string ?? nil
                user.avatar =   json["author"]["avatar"].string ?? nil
                feed.author = user
                
                feeds.append(feed)
            }
            
            success(feeds)
        }) { (err) in
            print(err)
        }
    }
}
    
