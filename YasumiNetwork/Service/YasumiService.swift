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

class NewsService: NSObject {
    
    static let shared = NewsService()
    
    func apiGet(path: String, options: [String: String], success : @escaping (_ result: JSON) -> Void, error: @escaping (Error) -> Void) {
        
        var endpoint = "\(Constants.apiBaseUrl)/\( Constants.apiVersion)\(path)"
        
        // Add paramester
        if options.count > 0 {
            endpoint = endpoint + "?"
            
            for (k, v) in options {
                endpoint += "\(k)=\(v)&"
            }
        }
        
        endpoint = endpoint.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        guard let _ = Ours.session else {
            return
        }
        
        // Add authen layer
        var authorization =  Ours.session.hashed_email + ":" + Ours.session.password
        authorization = (authorization.data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0)))!
        authorization = "Basic " + authorization
        let companyId = (Ours.session.companyId.data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0)))!
        
        let header: HTTPHeaders = [
            "Authorization": authorization,
            "X-Company-Key": companyId
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
                    let err = NSError(domain: Constants.apiBaseUrl, code: (json["error"]["code"].rawValue) as? Int ?? 00, userInfo: [NSLocalizedDescriptionKey: errStr])
                    error(err)
                    
                    return
                } else if response.response?.statusCode == 401 {
                    // Unauthenticate
                    let err = NSError(domain: Constants.apiBaseUrl, code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
                    error(err)
                    return
                } else if response.response?.statusCode != 200 {
                    // Unexpected error
                    let err = NSError(domain: Constants.apiBaseUrl, code: response.response?.statusCode ?? 00, userInfo: nil)
                    error(err)
                    return
                }
                
                // Nice
                success(json)
        }
    }
    
    func apiUpload(path: String, multipartFormData: @escaping (MultipartFormData) -> Void, success : @escaping (JSON) -> Void, error: @escaping (Error) -> Void) {
        let endpoint = "\(Constants.apiBaseUrl)/\( Constants.apiVersion)\(path)"
        
        // Add authen layer
        var authorization =  Ours.session.hashed_email + ":" + Ours.session.password
        authorization = (authorization.data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0)))!
        authorization = "Basic " + authorization
        let companyId = (Ours.session.companyId.data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0)))!
        
        let header: HTTPHeaders = [
            "Authorization": authorization,
            "X-Company-Key": companyId
        ]
        
        Alamofire.upload(multipartFormData: { (formData) in
            multipartFormData(formData)
        }, usingThreshold: UInt64.init(), to: endpoint, method: .post, headers: header) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard let object = response.result.value else {
                        error(response.result.error!)
                        return
                    }
                    
                    let json = JSON(object)
                    
                    if response.response?.statusCode != 200 {
                        if let errCode = json["error"]["code"].int {
                            let errMessage = json["error"]["message"].string ?? ""
                            let err = NSError(domain: Constants.apiBaseUrl, code: errCode, userInfo: [NSLocalizedDescriptionKey: errMessage])
                            error(err)
                        } else {
                            let err = NSError(domain: Constants.apiBaseUrl, code: response.response?.statusCode ?? 00, userInfo: nil)
                            error(err)
                        }
                    }
                    else {
                        success(json)
                    }
                }
            case .failure(let encodingError):
                error(encodingError)
            }
        }
    }
    
    func apiPost(path: String, options: [String: String], skipAuthen: Bool = false, success : @escaping (_ result: JSON) -> Void, error: @escaping (Error) -> Void) {
        
        let endpoint = "\(Constants.apiBaseUrl)/\( Constants.apiVersion)\(path)"
        // Add authen layer
        var header: HTTPHeaders?
        
        if skipAuthen == false {
            var authorization =  Ours.session.hashed_email + ":" + Ours.session.password
            authorization = (authorization.data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0)))!
            authorization = "Basic " + authorization
            let companyId = (Ours.session.companyId.data(using: String.Encoding.utf8)?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0)))!
            
            header = [
                "Authorization": authorization,
                "X-Company-Key": companyId
            ]
        }
        
        Alamofire.request(endpoint, method: HTTPMethod.post, parameters: options, encoding: URLEncoding.default, headers: header)
            .responseJSON { response in
                
                guard let object = response.result.value else {
                    error(response.result.error!)
                    return
                }
                
                let json = JSON(object)
                
                if let httpCode = response.response?.statusCode {
                    switch httpCode {
                    case 200:
                        // Nice request
                        success(json)
                    case 400:
                        // Bad request
                        let errStr = json["error"]["message"].rawValue
                        let err = NSError(domain: Constants.apiBaseUrl, code: (json["error"]["code"].rawValue) as? Int ?? 00, userInfo: [NSLocalizedDescriptionKey: errStr])
                        error(err)
                    case 401:
                        // Unauthorized
                        let err = NSError(domain: Constants.apiBaseUrl, code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
                        error(err)
                    default:
                        // Unexpected error
                        let err = NSError(domain: Constants.apiBaseUrl, code: response.response?.statusCode ?? 00, userInfo: nil)
                        error(err)
                    }
                } else {
                    // No internet connection
                    let err = NSError(domain: Constants.apiBaseUrl, code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't connect"])
                    error(err)
                }
        }
    }
    
    func apiEditPost(multipartFormData: @escaping (MultipartFormData) -> Void, success : @escaping (_ result: Article) -> Void, error: @escaping (Error) -> Void) {
        apiUpload(path: "/articles/edit.json", multipartFormData: { (formData) in
            multipartFormData(formData)
        }, success: { (json) in
            let article = Article()
            
            article.id = json["id"].string!
            article.text = json["message"].string ?? ""
            
            article.name = Ours.session.name
            article.avatar = Ours.session.avatar
            article.user_id = Ours.session.id
            
            // External link
            if let _ = json["external_link"]["id"].string {
                article.has_external_link = true
                
                article.el_preview_image = json["external_link"]["preview_image"].string ?? ""
                article.el_message = json["external_link"]["text"].string ?? ""
                article.el_url = json["external_link"]["url"].string ?? ""
            }
            
            article.preview_image = json["preview_image"].string ?? ""
            
            let likeCount = json["ours_like_count"].string ?? "0"
            article.ourLikeCount = Int(likeCount)!
            
            let commentCount = json["ours_comment_count"].string ?? "0"
            article.ourCommentCount = Int(commentCount)!
            
            article.platform = 6
            
            article.read = json["read"].boolValue
            article.liked = json["liked"].boolValue
            article.favorited = json["favorited"].boolValue
            
            // Media
            if json["medias"].count > 0 {
                for (_, mediaJson): (String,JSON) in json["medias"] {
                    
                    if let type = mediaJson["type"].string, type == "video" {
                        if let videoUrl = mediaJson["url"].string {
                            let realmMedia = RealmMedia(value: ["type": 2, "mediaHttpsUrl": videoUrl])
                            article.medias.append(realmMedia)
                        }
                    }
                    else {
                        if let pictureUrl = mediaJson["url"].string {
                            let realmMedia = RealmMedia(value: ["type": 1, "mediaHttpsUrl": pictureUrl])
                            article.medias.append(realmMedia)
                        }
                    }
                }
            }
            
            // Hashtag
            for (_, tagJson): (String, JSON) in json["hashtags"] {
                let tag = Hashtag(tagId: tagJson["hashtag_id"].string!, tagName: tagJson["tag_name"].string ?? "")
                article.hashtags.append(tag)
            }
            
            let dateStr: String = json["published_at"].string ?? ""
            if let date = NSDate().convertTimeToTimeInterVal(time: dateStr, format: "yyyy-MM-dd HH:mm:ss") {
                article.publishedTime = date + Ours.secondsFromTokyoTime
            }
            
            article.updated_date = json["updated_date"].string ?? ""
            
            success(article)
        }) { (err) in
            error(err)
        }
    }
    
    
    func apiCreatePost(multipartFormData: @escaping (MultipartFormData) -> Void, success : @escaping (_ result: Article) -> Void, error: @escaping (Error) -> Void) {
        apiUpload(path: "/articles/create.json", multipartFormData: { (formData) in
            multipartFormData(formData)
        }, success: { (json) in
            let post = Article()
            
            post.text = json["message"].string ?? ""
            
            success(post)
            
        }) { (err) in
            error(err)
        }
    }
    
    func apiUpdateProfile(multipartFormData: @escaping (MultipartFormData) -> Void, success : @escaping (User) -> Void, error: @escaping (Error) -> Void) {
        apiUpload(path: "/users/update_profile.json", multipartFormData: { (formData) in
            multipartFormData(formData)
        }, success: { (json) in
            let user = self.setUserInfor(userInfo: json)
            
            success(user)
            
        }) { (err) in
            error(err)
        }
    }
    
    func apiFollow(options: [String: String], success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        let accounts = Ours.db.objects(Account.self).filter("isActivate = true")
        
        var account_ids = ""
        
        for account in accounts {
            account_ids += "\(account.id),"
        }
        
        apiPost(path: "/accounts/follow.json", options: ["account_ids": account_ids], success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiGetUnreadCount(success : @escaping (Int) -> Void, error: @escaping (Error) -> Void) {
        apiGet(path: "/users/read.json", options: [:], success: { (json) in
            let unreadCount = json["unread_count"].int ?? 0
            success(unreadCount)
        }) { (err) in
            error(err)
        }
    }
    
    func apiActiveLog(options: [String: String], success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        apiPost(path: "/users/getActive.json", options: options, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiDeletePost(options: [String: String], success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        apiPost(path: "/articles/delete.json", options: options, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiUpdateNotificationToken(options: [String: String], success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        apiPost(path: "/users/device.json", options: options, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiEnableNotification(success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        
        let options = [
            "device_id": UIDevice.current.identifierForVendor!.uuidString
        ]
        
        apiPost(path: "/users/notification/enable.json", options: options, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiDisableNotification(success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        
        let options = [
            "device_id": UIDevice.current.identifierForVendor!.uuidString
        ]
        
        apiPost(path: "/users/notification/disable.json", options: options, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiPostLike(articleId: String, success : @escaping (_ result: Int) -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "article_id": articleId
        ]
        
        apiPost(path: "/users/like/create.json", options: options, success: { (json) in
            let likeCount = json["like_count"].int ?? 0
            success(likeCount)
        }) { (err) in
            error(err)
        }
    }
    
    func apiPostUnlike(articleId: String, success : @escaping (_ result: Int) -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "article_id": articleId
        ]
        
        apiPost(path: "/users/like/destroy.json", options: options, success: { (json) in
            let likeCount = json["like_count"].int ?? 0
            success(likeCount)
        }) { (err) in
            error(err)
        }
    }
    
    func apiPostStar(articleId: String, success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "article_id": articleId
        ]
        
        apiPost(path: "/users/star/create.json", options: options, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiPostUnstar(articleId: String, success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "article_id": articleId
        ]
        
        apiPost(path: "/users/star/destroy.json", options: options, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiPostHashtag(tagId: String, success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "hashtag_id": tagId
        ]
        apiPost(path: "/Tags/follow_tag.json", options: options, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiPostUnHashtag(tagId: String, success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "hashtag_id": tagId
        ]
        
        apiPost(path: "/Tags/unfollow_tag.json", options: options, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiPostAuthSlack(userId: String, code: String, success: @escaping (String) -> Void, error: @escaping (Error) -> Void) {
        var options: [String: String] = [:]
        options["user_id"] = userId
        options["code"] = code
        
        apiPost(path: "/users/auth_slack.json", options: options, success: { (json) in
            success(json[0].string ?? "")
        }) { (err) in
            error(err)
        }
        
    }
    
    
    func apiMarkArticleAsRead(articleId: String, success : @escaping (Int) -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "article_id": articleId
        ]
        
        apiPost(path: "/users/read.json", options: options, success: { (json) in
            let unreadCount = json["unread_count"].int ?? 0
            success(unreadCount)
        }) { (err) in
            error(err)
        }
    }
    
    func apiChangePassword(password: String, newPassword: String, success : @escaping (_ result: User) -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "email":        Ours.session.email,
            "password":     password,
            "new_password":  newPassword
        ]
        
        apiPost(path: "/users/update_password.json", options: options, skipAuthen: false, success: { (json) in
            
            let user = self.setUserInfor(userInfo: json)
            
            success(user)
        }) { (err) in
            error(err)
        }
    }
    
    func apiRequestResetPwd(email: String, success : @escaping () -> Void, error: @escaping (Error) -> Void) {
        let options = ["email": email]
        
        apiPost(path: "/Users/request_reset_password.json", options: options, skipAuthen: true, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiLogin(email: String, password: String, success : @escaping (_ result: User) -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "email":    email,
            "password": password
        ]
        
        apiPost(path: "/Users/login.json", options: options, skipAuthen: true, success: { (json) in
            
            // Basic information
            let user = self.setUserInfor(userInfo: json)
            user.host = Constants.apiBaseUrl
            user.companyId = json["company_id"].string ?? ""
            
            // Favorite item
            for (_, item):(String, JSON) in json["star"] {
                let star = Favorite(value: ["id": item.string!])
                user.star.append(star)
            }
            
            for (_, item):(String, JSON) in json["like"] {
                let like = Like(value: ["id": item.string!])
                user.like.append(like)
            }
            
            Ours.session = user
            
            success(user)
        }) { (err) in
            error(err)
        }
    }
    
    func apiPostCommentShareNew(articleID: String, message: String,  success : @escaping (Comment) -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "article_id" : articleID,
            "message"   : message
        ]
        apiPost(path: "/Comments/post.json", options: options, success: { (json) in
            let comment = Comment()
            comment.avatar = json["owner_avatar"].string ?? ""
            comment.text = json["message"].string   ?? ""
            comment.name = json["owner_name"].string ?? ""
            comment.id = json["id"].string ?? ""
            
            // Author
            if let _ = json["from"]["id"].string {
                let author = self.setUserInfor(userInfo: json["from"], option: true)
                comment.author = author
            }
            
            let dateStr: String = json["created_at"].string ?? ""
            
            if let date = NSDate().convertTimeToTimeInterVal(time: dateStr, format: "yyyy-MM-dd HH:mm:ss") {
                comment.createdAt = date + Ours.secondsFromTokyoTime
            }
            
            success(comment)
        }) { (err) in
            error(err)
        }
        
    }
    
    func apiGetUserLikePost(options: [String: String], success : @escaping (_ result: [User], _ lastRecordTime: TimeInterval?) -> Void, error: @escaping (Error) -> Void) {
        apiGet(path: "/articles/like_list.json", options: options, success: { (response) in
            var users = [User]()
            
            // For paging
            var lastRecordTime: TimeInterval?
            
            response.forEach({ (_, json) in
                
                let user = self.setUserInfor(userInfo: json, option: true)
                if let date = NSDate().convertTimeToTimeInterVal(time: json["created_at"].string!, format: "yyyy-MM-dd HH:mm:ss") {
                    lastRecordTime = date + Ours.secondsFromTokyoTime
                }
                
                users.append(user)
            })
            
            success(users, lastRecordTime)
        }) { (err) in
            error(err)
        }
    }
    
    func apiGetAccount(success : @escaping (_ result: [Account]) -> Void, error: @escaping (Error) -> Void) {
        apiGet(path: "/accounts.json", options: [:], success: { (resonse) in
            
            var accounts = [Account]()
            
            resonse.forEach { (_, json) in
                let account = Account()
                
                switch json["platform"].string! {
                case "facebook":
                    account.articleType = .facebook
                case "twitter":
                    account.articleType = .twitter
                case "instagram":
                    account.articleType = .instagram
                case "blog":
                    account.articleType = .blog
                default:
                    account.articleType = .internalNews
                }
                
                account.id =            json["id"].string!
                account.accountName =   json["name"].string ?? ""
                account.avatar =        json["icon"].string ?? ""
                account.userName =      json["username"].string ?? ""
                account.accountId =     json["id"].string ?? ""
                
                // In case of use old server
                account.isActivate =    json["followed"].bool ?? true
                
                accounts.append(account)
            }
            success(accounts)
            
        }) { (err) in
            error(err)
        }
    }
    
    func apiGetMyPost(options: [String: String], success : @escaping (_ result: [Article]) -> Void, error: @escaping (Error) -> Void) {
        apiGet(path: "/users/user_page.json", options: options, success: { (respon) in
            var articles = [Article]()
            
            respon.forEach({ (_, json) in
                let article = Article()
                
                article.id = json["id"].string!
                article.text = json["message"].string ?? ""
                article.read = json["read"].boolValue
                
                article.name = Ours.session.name
                article.avatar = Ours.session.avatar
                
                article.platform = 6
                article.account_id = json["account_id"].string ?? ""
                
                // External link
                if let _ = json["external_link"]["id"].string {
                    article.has_external_link = true
                    
                    article.el_preview_image = json["external_link"]["preview_image"].string ?? ""
                    article.el_message = json["external_link"]["text"].string ?? ""
                    article.el_url = json["external_link"]["url"].string ?? ""
                }
                
                article.preview_image = json["preview_image"].string ?? ""
                
                let likeCount = json["ours_like_count"].string ?? "0"
                article.ourLikeCount = Int(likeCount)!
                
                let commentCount = json["ours_comment_count"].string ?? "0"
                article.ourCommentCount = Int(commentCount)!
                
                // Media
                if json["medias"].count > 0 {
                    for (_, mediaJson): (String,JSON) in json["medias"] {
                        
                        if let type = mediaJson["type"].string, type == "video" {
                            if let videoUrl = mediaJson["url"].string {
                                let realmMedia = RealmMedia(value: ["type": 2, "mediaHttpsUrl": videoUrl])
                                article.medias.append(realmMedia)
                            }
                        }
                        else {
                            if let pictureUrl = mediaJson["url"].string {
                                let realmMedia = RealmMedia(value: ["type": 1, "mediaHttpsUrl": pictureUrl])
                                article.medias.append(realmMedia)
                            }
                        }
                    }
                }
                
                // Hashtag
                for (_, tagJson): (String, JSON) in json["hashtags"] {
                    let tag = Hashtag(tagId: tagJson["hashtag_id"].string!, tagName: tagJson["tag_name"].string ?? "")
                    article.hashtags.append(tag)
                }
                
                let dateStr: String = json["published_at"].string ?? ""
                if let date = NSDate().convertTimeToTimeInterVal(time: dateStr, format: "yyyy-MM-dd HH:mm:ss") {
                    article.publishedTime = date + Ours.secondsFromTokyoTime
                }
                
                articles.append(article)
            })
            
            success(articles)
        }) { (err) in
            error(err)
        }
    }
    
    func apiSearchTag(keyword: String, success : @escaping (_ result: [Hashtag]) -> Void, error: @escaping (Error) -> Void) {
        
        let k = keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        apiGet(path: "/Tags/search_hashtag.json?keyword=\(k!)", options: [String: String](), success: { (response) in
            
            // (tagId, tagName)
            var hashtags = [Hashtag]()
            
            response.forEach({ (_, json) in
                let tagId = json["id"].string!
                let tagName = json["tag_name"].string ?? ""
                
                hashtags.append(Hashtag(tagId: tagId, tagName: tagName))
            })
            
            success(hashtags)
        }) { (err) in
            print("Get hashtag fail")
            print(err)
        }
    }
    
    func apiSearchTagFollow(keyword: String, tab: String, success : @escaping (_ result: [Hashtag]) -> Void, error: @escaping (Error) -> Void) {
        
        let k = keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        apiGet(path: "/Tags/search_tag.json?keyword=\(k!)&tab=\(tab)", options: [String: String](), success: { (response) in
            
            // (tagId, tagName)
            var hashtags = [Hashtag]()
            
            response.forEach({ (_, json) in
                let hashtag = Hashtag(tagId: "", tagName: "")
                hashtag.id          = json["id"].string ?? ""
                hashtag.tagId       = json["hashtag_id"].string ?? ""
                hashtag.tagName     = json["tag_name"].string ?? ""
                hashtag.isFollow    = json["is_follow"].bool ?? false
                hashtags.append(hashtag)
            })
            success(hashtags)
        }) { (err) in
            print("Get hashtag fail")
            print(err)
        }
    }
    
    func apiGetArticle(options: [String: String], success : @escaping (_ result: [Article]) -> Void, error: @escaping (Error) -> Void) {
        apiGet(path: "/articles.json", options: options, success: { (resonse) in
            var articles = [Article]()
            
            resonse.forEach { (_, json) in
                var article = Article()
                if json.count > 0 {
                    article = self.reformatArticle(json)
                    // group article which the same link
                    if json["group_articles"].count > 0 {
                        for (_, sameLinks): (String, JSON) in json["group_articles"] {
                            let groupArticle = self.reformatArticle(sameLinks)
                            article.group_articles.append(groupArticle)
                        }
                    }
                    articles.append(article)
                }
            }
            
            success(articles)
            
        }) { (err) in
            error(err)
        }
    }
    
    func reformatArticle(_ json: JSON) -> Article {
        let article = Article()
        article.read = json["read"].boolValue
        article.liked = json["liked"].boolValue
        article.favorited = json["favorited"].boolValue
        
        switch json["from"]["platform_id"].string! {
        case "1":
            article.avatar = json["from"]["icon"].string ?? ""
        case "2":
            if let avatar = json["from"]["icon"].string {
                let largeAvatar: String = avatar.replacingOccurrences(of: "_normal", with: "")
                article.avatar = largeAvatar
            }
        case "3":
            article.avatar = json["from"]["icon"].string ?? ""
        case "6":
            article.avatar = json["user_infor"]["avatar"].string ?? ""
            article.name = json["user_infor"]["name"].string ?? ""
        default:
            article.avatar = json["from"]["icon"].string ?? ""
            article.shortContent = json["description"].string ?? ""
            article.contentEncoded = json["message"].string ?? ""
        }
        
        article.platform = Int(json["from"]["platform_id"].string!)!
        article.name = json["from"]["name"].string ?? ""
        
        article.user_id = json["user_infor"]["id"].string ?? ""
        article.text = json["message"].string ?? ""
        article.id = json["id"].string!
        article.preview_image = json["preview_image"].string ?? ""
        article.permalinkUrl = json["permalink"].string ?? ""
        let accountLike = json["ours_like_count"].string ?? "0"
        article.ourLikeCount = Int(accountLike)!
        article.media_id = json["origin_id"].string ?? ""
        article.account_id = json["account_id"].string ?? ""
        
        // Author
        if let _ = json["user_infor"]["id"].string {
            let user = self.setUserInfor(userInfo: json["user_infor"], option: true)
            article.author = user
        }
        
        //media
        if json["medias"].count > 0 {
            for (_, mediaJson): (String,JSON) in json["medias"] {
                
                if let type = mediaJson["type"].string, type == "video" {
                    if let videoUrl = mediaJson["url"].string {
                        let realmMedia = RealmMedia(value: ["type": 2, "mediaHttpsUrl": videoUrl])
                        article.medias.append(realmMedia)
                    }
                }
                else {
                    if let pictureUrl = mediaJson["url"].string {
                        let realmMedia = RealmMedia(value: ["type": 1, "mediaHttpsUrl": pictureUrl])
                        article.medias.append(realmMedia)
                    }
                }
            }
        }
        
        let dateStr: String = json["published_at"].string!
        
        if let date = NSDate().convertTimeToTimeInterVal(time: dateStr, format: "yyyy-MM-dd HH:mm:ss") {
            article.publishedTime = date + Ours.secondsFromTokyoTime
        }
        
        article.updated_date = json["updated_date"].string ?? ""
        
        // External link
        if let _ = json["external_link"]["id"].string {
            article.has_external_link = true
            article.el_preview_image = json["external_link"]["preview_image"].string ?? ""
            article.el_message = json["external_link"]["text"].string ?? ""
            article.el_url = json["external_link"]["url"].string ?? ""
        }
        
        // Hashtag
        for (_, tagJson): (String, JSON) in json["hashtags"] {
            let tag = Hashtag(tagId: tagJson["hashtag_id"].string!, tagName: tagJson["tag_name"].string ?? "")
            article.hashtags.append(tag)
        }
        
        let likeCount = json["ours_like_count"].string ?? "0"
        article.ourLikeCount = Int(likeCount)!
        
        let commentCount = json["ours_comment_count"].string ?? "0"
        article.ourCommentCount = Int(commentCount)!
        
        article.like = json["like_count"].string ?? ""
        article.comment = json["comment_count"].string ?? ""
        article.share = json["share_count"].string ?? ""
        article.retweet = json["retweet_count"].string ?? ""
        
        return article
    }
    func apiGetComment(options: [String: String], success : @escaping (_ result: [Comment]) -> Void, error: @escaping (Error) -> Void) {
        apiGet(path: "/comments.json", options: options, success: { (resonse) in
            
            var comments = [Comment]()
            
            resonse.forEach { (_, json) in
                let comment = Comment()
                comment.id          = json["id"].string!
                comment.text        = json["message"].string!
                comment.name        = json["owner_name"].string ?? ""
                
                if let date = NSDate().convertTimeToTimeInterVal(time: json["created_at"].string!, format: "yyyy-MM-dd HH:mm:ss") {
                    comment.createdAt = date + Ours.secondsFromTokyoTime
                }
                
                comment.updated_date = json["updated_date"].string ?? ""
                
                if let platformId = json["platform_id"].string, platformId == "1" {
                    if json["owner_origin_id"].string != "" {
                        comment.avatar = "https://graph.facebook.com/" + json["owner_origin_id"].string! + "/picture?type=normal"
                    } else {
                        comment.avatar = ""
                    }
                }
                else {
                    comment.avatar = json["owner_avatar"].string ?? ""
                }
                
                // Author
                if let _ = json["from"]["id"].string {
                    let author = self.setUserInfor(userInfo: json["from"], option: true)
                    comment.author = author
                }
                
                comments.append(comment)
            }
            success(comments)
            
        }) { (err) in
            error(err)
        }
    }
    
    func apiDeleteComment(option: [String: String], success: @escaping () -> Void, error: @escaping (Error) -> Void) {
        apiPost(path: "/Comments/delete.json", options: option, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiEditComment(option: [String: String], success: @escaping (_ result: Comment) -> Void, error: @escaping (Error) -> Void) {
        apiPost(path: "/Comments/edit.json", options: option, success: { (json) in
            let comment = Comment()
            comment.avatar = json["owner_avatar"].string ?? ""
            comment.text = json["message"].string   ?? ""
            comment.name = json["owner_name"].string ?? ""
            comment.id = json["id"].string ?? ""
            
            let dateStr: String = json["created_at"].string ?? ""
            
            if let date = NSDate().convertTimeToTimeInterVal(time: dateStr, format: "yyyy-MM-dd HH:mm:ss") {
                comment.createdAt = date + Ours.secondsFromTokyoTime
            }
            
            comment.updated_date = json["updated_date"].string ?? ""
            
            success(comment)
        }) { (err) in
            error(err)
        }
    }
    
    func apiDisConnect(option: [String: String], success: @escaping ()-> Void, error: @escaping (Error) ->  Void) {
        apiPost(path: "/users/disconnect.json", options: option, success: { (json) in
            success()
        }) { (err) in
            error(err)
        }
    }
    
    func apiGetHashtag(options: [String:String], success: @escaping (_ result: [Hashtag]) -> Void, error: @escaping (Error) -> Void) {
        apiGet(path: "/tags.json", options: options, success: { (response) in
            var hashtags = [Hashtag]()
            response.forEach({ (_, json) in
                let hashtag = Hashtag(tagId: "", tagName: "")
                hashtag.id          = json["id"].string ?? ""
                hashtag.tagId       = json["hashtag_id"].string ?? ""
                hashtag.tagName     = json["tag_name"].string ?? ""
                hashtag.isFollow    = json["is_follow"].bool ?? false
                hashtags.append(hashtag)
            })
            success(hashtags)
        }) { (err) in
            error(err)
        }
    }
    
    func apiGetBookmark(success: @escaping (Array<String>) -> Void, error: @escaping (Error) -> Void) {
        apiGet(path: "/users/bookmarks.json", options: [:], success: { (response) in
            var bookmarks : [String] = []
            response.forEach({ (_, json) in
                let bookmark = json.string ?? ""
                bookmarks.append(bookmark)
            })
            success(bookmarks)
        }) { (err) in
            error(err)
        }
    }
    
    func apiGetReactionDetail(type: String, success: @escaping (_ result: Array<Any>) -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "type": type
        ]
        apiGet(path: "/users/reaction.json", options: options, success: { (response) in
            
            var likes = [Like]()
            var favorites = [Favorite]()
            
            response.forEach({ (_, json) in
                
                // Article item
                if let _ = json["article"]["id"].string {
                    
                    let article = Article()
                    let temp = json["article"]
                    
                    article.read = temp["read"].boolValue
                    article.liked = temp["liked"].boolValue
                    article.favorited = temp["favorited"].boolValue
                    
                    switch temp["from"]["platform_id"].string! {
                    case "1":
                        article.avatar = temp["from"]["icon"].string ?? ""
                    case "2":
                        if let avatar = temp["from"]["icon"].string {
                            let largeAvatar: String = avatar.replacingOccurrences(of: "_normal", with: "")
                            article.avatar = largeAvatar
                        }
                    case "3":
                        article.avatar = temp["from"]["icon"].string ?? ""
                    case "6":
                        article.avatar = temp["user_infor"]["avatar"].string ?? ""
                        article.name = temp["user_infor"]["name"].string ?? ""
                    default:
                        article.avatar = temp["from"]["icon"].string ?? ""
                        article.shortContent = temp["description"].string ?? ""
                        article.contentEncoded = temp["message"].string ?? ""
                    }
                    
                    article.platform = Int(temp["from"]["platform_id"].string!)!
                    article.name = temp["from"]["name"].string ?? ""
                    
                    article.user_id = temp["user_infor"]["id"].string ?? ""
                    article.text = temp["message"].string ?? ""
                    article.id = temp["id"].string!
                    article.preview_image = temp["preview_image"].string ?? ""
                    article.permalinkUrl = temp["permalink"].string ?? ""
                    let accountLike = temp["ours_like_count"].string ?? "0"
                    article.ourLikeCount = Int(accountLike)!
                    article.media_id = temp["origin_id"].string ?? ""
                    article.account_id = temp["account_id"].string ?? ""
                    
                    // Author
                    if let _ = temp["user_infor"]["id"].string {
                        let user = self.setUserInfor(userInfo: temp["user_infor"],option: true)
                        article.author = user
                    }
                    
                    //media
                    if temp["medias"].count > 0 {
                        for (_, mediaJson): (String,JSON) in temp["medias"] {
                            
                            if let type = mediaJson["type"].string, type == "video" {
                                if let videoUrl = mediaJson["url"].string {
                                    let realmMedia = RealmMedia(value: ["type": 2, "mediaHttpsUrl": videoUrl])
                                    article.medias.append(realmMedia)
                                }
                            }
                            else {
                                if let pictureUrl = mediaJson["url"].string {
                                    let realmMedia = RealmMedia(value: ["type": 1, "mediaHttpsUrl": pictureUrl])
                                    article.medias.append(realmMedia)
                                }
                            }
                        }
                    }
                    
                    let dateStr: String = temp["published_at"].string!
                    
                    if let date = NSDate().convertTimeToTimeInterVal(time: dateStr, format: "yyyy-MM-dd HH:mm:ss") {
                        article.publishedTime = date + Ours.secondsFromTokyoTime
                    }
                    
                    article.updated_date = temp["updated_date"].string ?? ""
                    
                    // External link
                    if let _ = temp["external_link"]["id"].string {
                        article.has_external_link = true
                        article.el_preview_image = temp["external_link"]["preview_image"].string ?? ""
                        article.el_message = temp["external_link"]["text"].string ?? ""
                        article.el_url = temp["external_link"]["url"].string ?? ""
                    }
                    
                    // Hashtag
                    for (_, tagJson): (String, JSON) in temp["hashtags"] {
                        let tag = Hashtag(tagId: tagJson["hashtag_id"].string!, tagName: tagJson["tag_name"].string ?? "")
                        article.hashtags.append(tag)
                    }
                    
                    let likeCount = temp["ours_like_count"].string ?? "0"
                    article.ourLikeCount = Int(likeCount)!
                    
                    let commentCount = temp["ours_comment_count"].string ?? "0"
                    article.ourCommentCount = Int(commentCount)!
                    
                    article.like = temp["like_count"].string ?? ""
                    article.comment = temp["comment_count"].string ?? ""
                    article.share = temp["share_count"].string ?? ""
                    article.retweet = temp["retweet_count"].string ?? ""
                    
                    if type == "2" {
                        let favorite = Favorite()
                        
                        // Favorite item
                        favorite.id = temp["id"].string!
                        favorite.article = article
                        let dateFavorite: String = json["created_at"].string ?? ""
                        if let date = NSDate().convertTimeToTimeInterVal(time: dateFavorite, format: "yyyy-MM-dd HH:mm:ss") {
                            favorite.create_at = date
                        }
                        
                        favorites.append(favorite)
                    } else if type == "1" {
                        let like = Like()
                        
                        // Like item
                        like.id = temp["id"].string!
                        like.article = article
                        
                        likes.append(like)
                    }
                }
            })
            
            if type == "2" {
                success(favorites)
            } else if type == "1" {
                success(likes)
            } else {
                success(Array())
            }
        }) { (err) in
            error(err)
        }
    }
    
    func apiGetUserInformation(userId: String?, success : @escaping (_ result: User) -> Void, error: @escaping (Error) -> Void) {
        
        var options = [String: String]()
        
        if let _ = userId {
            options["user_id"] = userId
        }
        
        apiGet(path: "/users/user_information.json", options: options, success: { (json) in
            
            let user = self.setUserInfor(userInfo: json)
            success(user)
        }) { (err) in
            error(err)
        }
    }
    
    func apiCheckAccessToken(success: @escaping (_ result: [String: [String: Bool]]) -> Void, error: @escaping (Error) -> Void) {
        //        var options = [String: String]()
        //        if let _ = userId {
        //            options["user_id"] = userId
        //        }
        apiPost(path: "/users/check_oauth.json", options: [:], success: { (json) in
            var data = [String: [String: Bool]]()
            
            var tempChatwork = [String: Bool]()
            tempChatwork["is_register"] = json["chatwork"]["is_register"].boolValue
            tempChatwork["is_expired"] = json["chatwork"]["is_expired"].boolValue
            data["chatwork"] = tempChatwork
            
            var tempKDDI = [String: Bool]()
            tempKDDI["is_register"] = json["kddi"]["is_register"].boolValue
            tempKDDI["is_expired"] = json["kddi"]["is_expired"].boolValue
            data["kddi"] = tempKDDI
            
            var tempSlack = [String: Bool]()
            tempSlack["is_register"] = json["slack"]["is_register"].boolValue
            tempSlack["is_expired"] = json["slack"]["is_expired"].boolValue
            data["slack"] = tempSlack
            
            success(data)
        }) { (err) in
            print("Error \(err.localizedDescription)")
            error(err)
        }
    }
    
    func apiGetWorkspace(success: @escaping (_ result: [(name: String, is_expired: Bool)]) -> Void, error: @escaping (Error) -> Void) {
        apiGet(path: "/Users/get_list_workspace.json", options: [:], success: { (respone) in
            var datas = [(name: String, is_expired: Bool)]()
            
            respone.forEach({ (_, json) in
                
                
                let name  = json["name"].string ?? ""
                let is_expired = json["is_expired"].boolValue
                
                let data = (name: name, is_expired: is_expired)
                
                datas.append(data)
                
            })
            success(datas)
            
        }) { (err) in
            error(err)
        }
    }
    
    func setUserInfor(userInfo: JSON, option: Bool = false) -> User {
        let user = User()
        
        if option {
            user.id = userInfo["id"].string!
        }else {
            user.id = userInfo["id"].string ?? ""
        }
        
        user.name = userInfo["name"].string ?? ""
        user.nickname = userInfo["nickname"].string ?? ""
        user.avatar = userInfo["avatar"].string ?? ""
        user.email =  userInfo["email"].string ?? ""
        user.hashed_email = userInfo["hashed_email"].string ?? ""
        user.password = userInfo["password"].string ?? ""
        user.group1 = userInfo["group1"].string ?? ""
        user.group2 = userInfo["group2"].string ?? ""
        user.comment = userInfo["comment"].string ?? ""
        return user
    }
    
    func memberSearch(keyword: String, success: @escaping (_ result: [User]) -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "keyword" : keyword
        ]
        
        apiGet(path: "/Search/search_member.json", options: options, success: { (response) in
            
            var users = [User]()
            
            response.forEach({ (_, json) in
                let user = User()
                
                user.id = json["id"].string!
                user.name = json["name"].string!
                user.nickname = json["nickname"].string ?? ""
                user.avatar = json["avatar"].string ?? ""
                user.comment = json["comment"].string ?? ""
                
                users.append(user)
            })
            
            success(users)
        }) {
            (err) in
            error(err)
        }
    }
    
    func articleSearch(options: [String:String], success : @escaping (_ result: Array<Article>) -> Void, error: @escaping (Error) -> Void) {
        
        apiGet(path: "/search.json", options: options, success: { (response) in
            var articles = [Article]()
            
            response.forEach { (_, json) in
                var article = Article()
                if json.count > 0 {
                    article = self.reformatArticle(json)
                    
                    // group article which the same link
                    if json["group_articles"].count > 0 {
                        for (_, sameLinks): (String, JSON) in json["group_articles"] {
                            let groupArticle = self.reformatArticle(sameLinks)
                            article.group_articles.append(groupArticle)
                        }
                    }
                    articles.append(article)
                }
            }
            
            success(articles)
        }) { (err) in
            print("get search result fail")
            print(err)
        }
    }
    
    func apiGetWithoutAuth(path: String, options: [String: String], success : @escaping (_ result: JSON) -> Void, error: @escaping (Error) -> Void) {
        var endpoint = Constants.apiBaseUrl + path
        
        endpoint = endpoint.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        Alamofire.request(endpoint, method: .get, parameters: options, encoding: URLEncoding.default).responseJSON { response in
            guard let object = response.result.value else {
                error(response.result.error!)
                return
            }
            
            let json = JSON(object)
            
            if response.response?.statusCode == 400 {
                // Bad request
                
                let errStr = json["error"]["message"].rawValue
                let err = NSError(domain: Constants.apiBaseUrl, code: (json["error"]["code"].rawValue) as? Int ?? 00, userInfo: [NSLocalizedDescriptionKey: errStr])
                error(err)
                
                return
            } else if response.response?.statusCode == 401 {
                // Unauthenticate
                let err = NSError(domain: Constants.apiBaseUrl, code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
                error(err)
                return
            } else if response.response?.statusCode != 200 {
                // Unexpected error
                let err = NSError(domain: Constants.apiBaseUrl, code: response.response?.statusCode ?? 00, userInfo: nil)
                error(err)
                return
            }
            
            // Nice
            success(json)
        }
    }
    func checkMaintainSchedule(success : @escaping (_ result: [String: String]) -> Void, error: @escaping (Error) -> Void) {
        let options = [String: String]()
        
        apiGetWithoutAuth(path: "/2.0/CheckMode/maintain.json", options: options, success: { (response) in
            var schedule = [String: String]()
            
            if response.count > 0 {
                schedule["start_time"] = response["start_time"].string!
                schedule["end_time"] = response["end_time"].string!
            }
            
            success(schedule)
        }) { (err) in
            error(err)
        }
    }
    
    func checkVersion(success : @escaping (_ result: Bool) -> Void, error: @escaping (Error) -> Void) {
        let options = [String: String]()
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let path = "/2.0/CheckMode/version.json?type=ios&version=" + appVersion!
        
        apiGetWithoutAuth(path: path, options: options, success: { (response) in
            var isNeedUpdate = false
            
            if response.count > 0 {
                isNeedUpdate = response["is_need_update"].bool ?? false
            }
            
            success(isNeedUpdate)
        }) { (err) in
            error(err)
        }
    }
    
    func apiReLogin(email: String, password: String, success : @escaping (_ result: User) -> Void, error: @escaping (Error) -> Void) {
        let options = [
            "email":    email,
            "password": password
        ]
        
        apiPost(path: "/Users/reLogin.json", options: options, skipAuthen: true, success: { (json) in
            
            // Basic information
            let user = self.setUserInfor(userInfo: json)
            user.companyId = json["company_id"].string!
            
            success(user)
        }) { (err) in
            error(err)
        }
    }
    
}

