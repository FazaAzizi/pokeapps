//
//  RegisterViewModel.swift
//  pokeapps
//
//  Created by Faza Azizi on 19/04/25.
//

import Foundation
import RxSwift
import RxCocoa

class RegisterViewModel {
    let username = BehaviorRelay<String>(value: "")
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let confirmPassword = BehaviorRelay<String>(value: "")
    let registerTapped = PublishSubject<Void>()
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let registrationResult = PublishSubject<Bool>()
    let errorMessage = PublishSubject<String>()
    
    private let userManager = UserManager.shared
    private let disposeBag = DisposeBag()
    
    init() {
        registerTapped
            .withLatestFrom(Observable.combineLatest(username, email, password, confirmPassword))
            .do(onNext: { [weak self] _ in self?.isLoading.accept(true) })
            .flatMap { [weak self] (username, email, password, confirmPassword) -> Observable<Bool> in
                guard let self = self else { return Observable.just(false) }
                
                // Validate inputs
                if username.isEmpty || email.isEmpty || password.isEmpty {
                    self.errorMessage.onNext("All fields are required")
                    self.isLoading.accept(false)
                    return Observable.just(false)
                }
                
                if password != confirmPassword {
                    self.errorMessage.onNext("Passwords do not match")
                    self.isLoading.accept(false)
                    return Observable.just(false)
                }
                
                if !self.isValidEmail(email) {
                    self.errorMessage.onNext("Please enter a valid email address")
                    self.isLoading.accept(false)
                    return Observable.just(false)
                }
                
                return self.userManager.registerUser(username: username, password: password, email: email)
            }
            .do(onNext: { [weak self] _ in self?.isLoading.accept(false) })
            .bind(to: registrationResult)
            .disposed(by: disposeBag)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

