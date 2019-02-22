//
//  User.swift
//  YasumiNetwork
//
//  Created by Quy Pham on 1/31/19.
//  Copyright © 2019 Quy Pham. All rights reserved.
//

import Foundation

enum Role {
    case admin
    case manager
    case user
}

class User {
    var id:     String = ""
    var name:   String?
    var email: String?
    var avatar: String?
    var dob: String?
    var country: String?
    var address: String?
    var quote: String?
    var dol: String?            // Day off remain
    var role: Role = .user      // Role is user as default
}

