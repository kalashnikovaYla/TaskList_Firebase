//
//  User.swift
//  TaskList
//
//  Created by sss on 11.01.2023.
//

import Foundation
import FirebaseAuth

struct User {
    let uid: String
    let email: String
    
    init(user: FirebaseAuth.User) {
        self.uid = user.uid
        self.email = user.email ?? ""
    }
}
