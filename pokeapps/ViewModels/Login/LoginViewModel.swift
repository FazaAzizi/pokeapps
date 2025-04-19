//
//  LoginViewModel.swift
//  pokeapps
//
//  Created by Faza Azizi on 19/04/25.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let loginTapped = PublishSubject<Void>()
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let loginResult = PublishSubject<Bool>()
    let errorMessage = PublishSubject<String>()
    
    private let userManager = UserManager.shared
    private let disposeBag = DisposeBag()
    
    init() {
        loginTapped
            .withLatestFrom(Observable.combineLatest(username, password))
            .do(onNext: { [weak self] _ in self?.isLoading.accept(true) })
            .flatMap { [weak self] (username, password) -> Observable<Bool> in
                guard let self = self else { return Observable.just(false) }
                
                if username.isEmpty || password.isEmpty {
                    self.errorMessage.onNext("Username and password cannot be empty")
                    self.isLoading.accept(false)
                    return Observable.just(false)
                }
                
                return self.userManager.loginUser(username: username, password: password)
            }
            .do(onNext: { [weak self] _ in self?.isLoading.accept(false) })
            .bind(to: loginResult)
            .disposed(by: disposeBag)
    }
}

