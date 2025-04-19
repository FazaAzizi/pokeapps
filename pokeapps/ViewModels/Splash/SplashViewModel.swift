//
//  SplashViewModel.swift
//  pokeapps
//
//  Created by Faza Azizi on 19/04/25.
//

import Foundation
import RxSwift
import RxCocoa

class SplashViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    let navigateToMain = PublishSubject<Void>()
    
    // MARK: - Initialization
    init() {
        // You can add any initialization logic here
        // For example, checking if user is logged in, loading initial data, etc.
    }
    
    // MARK: - Methods
    func startSplashTimer(duration: Double = 3.0) {
        // Simulate loading or initialization process
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.navigateToMain.onNext(())
        }
    }
    
    func checkUserLoginStatus() -> Bool {
        // Check if user is logged in
        // This is a placeholder - implement with your UserManager
        return UserManager.shared.isUserLoggedIn()
    }
}
