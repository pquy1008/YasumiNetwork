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
    
    func apiGet(path: String, options: [String: String], success : @escaping (_ result: JSON) -> Void, error: @escaping (Error) -> Void) {
        var endpoint = "\(Yasumi.apiBaseUri)/\(path)"
        
        // Add paramester
        if options.count > 0 {
            endpoint = endpoint + "?"
            
            for (k, v) in options {
                endpoint += "\(k)=\(v)&"
            }
        }
        
        // Add header
        let header: HTTPHeaders = [
            "user-email": "quypv@tmh-techlab.vn",
        ]
        
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
    
    func apiGetFeed(success : @escaping (_ result: [Feed]) -> Void) {
        apiGet(path: "/chatwork/api/home", options: [String:String](), success: { (res) in
            var feeds = [Feed]()

            res.forEach { (_, json) in
                let feed = Feed()
                
                feed.id =       json["id"].string!
                feed.userId =   json["user_id"].string!
                feed.start =    json["start"].string!
                feed.end =      json["end"].string!
                feed.date =     json["date"].string!
                feed.createAt = json["create_at"].string!
                feed.reason =   json["reason"].string!
                feed.emotion =  json["emotion"].string!
                feed.status =   json["status"].string!
                feed.time =     json["time"].string!
                feed.userName = json["user_name"].string!
                feed.info =     json["info"].string!
                feeds.append(feed)
            }
            
            success(feeds)
        }) { (err) in
            print(err)
        }
    }
}
    
