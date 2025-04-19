//
//  UserManager.swift
//  pokeapps
//
//  Created by Faza Azizi on 19/04/25.
//

import Foundation
import RealmSwift
import RxSwift

class UserManager {
    static let shared = UserManager()
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    func registerUser(username: String, password: String, email: String) -> Observable<Bool> {
        return Observable.create { observer in
            do {
                let existingUser = self.realm.objects(User.self).filter("username == %@", username).first
                if existingUser != nil {
                    observer.onNext(false)
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                try self.realm.write {
                    let user = User()
                    user.username = username
                    user.password = password
                    user.email = email
                    self.realm.add(user)
                }
                observer.onNext(true)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func loginUser(username: String, password: String) -> Observable<Bool> {
        return Observable.create { observer in
            let user = self.realm.objects(User.self)
                .filter("username == %@ AND password == %@", username, password)
                .first
            
            if let user = user {
                do {
                    try self.realm.write {
                        user.isLoggedIn = true
                    }
                    observer.onNext(true)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            } else {
                observer.onNext(false)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func logoutCurrentUser() -> Observable<Bool> {
        return Observable.create { observer in
            do {
                let currentUser = self.realm.objects(User.self).filter("isLoggedIn == true").first
                
                if let user = currentUser {
                    try self.realm.write {
                        user.isLoggedIn = false
                    }
                }
                
                observer.onNext(true)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func getCurrentUser() -> User? {
        return realm.objects(User.self).filter("isLoggedIn == true").first
    }
    
    func isUserLoggedIn() -> Bool {
        return getCurrentUser() != nil
    }
}
