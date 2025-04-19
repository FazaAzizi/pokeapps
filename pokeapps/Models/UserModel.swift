//
//  UserModel.swift
//  pokeapps
//
//  Created by Faza Azizi on 19/04/25.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var username = ""
    @objc dynamic var password = ""
    @objc dynamic var email = ""
    @objc dynamic var isLoggedIn = false
    
    override static func primaryKey() -> String? {
        return "username"
    }
}
