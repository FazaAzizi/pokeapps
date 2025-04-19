//
//  ProfileViewModel.swift
//  pokeapps
//
//  Created by Faza Azizi on 19/04/25.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel {
    let username = BehaviorRelay<String>(value: "")
    let email = BehaviorRelay<String>(value: "")
    let isLoading = BehaviorRelay<Bool>(value: false)
    let logoutSuccess = PublishSubject<Bool>()
    let error = PublishSubject<String>()
    
    private let userManager: UserManager
    private let disposeBag = DisposeBag()
    
    init(userManager: UserManager = UserManager.shared) {
        self.userManager = userManager
        loadUserData()
    }
    
    func loadUserData() {
        if let currentUser = userManager.getCurrentUser() {
            username.accept("\(currentUser.username)")
            email.accept("\(currentUser.email)")
        } else {
            username.accept("Username: Not logged in")
            email.accept("Email: Not available")
        }
    }
    
    func logout() {
        isLoading.accept(true)
        
        userManager.logoutCurrentUser()
            .subscribe(onNext: { [weak self] success in
                self?.isLoading.accept(false)
                self?.logoutSuccess.onNext(success)
            }, onError: { [weak self] error in
                self?.isLoading.accept(false)
                self?.error.onNext("Failed to logout: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
