//
//  SplashViewController.swift
//  pokeapps
//
//  Created by Faza Azizi on 19/04/25.
//

import UIKit
import RxSwift
import RxCocoa

class SplashViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel = SplashViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startSplashTimer()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        logoImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        
        activityIndicator.startAnimating()
    }
    
    private func bindViewModel() {
        viewModel.navigateToMain
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.navigateToMainScreen()
            })
            .disposed(by: disposeBag)
    }
    
    private func navigateToMainScreen() {
        if viewModel.checkUserLoginStatus() {
            let mainTabBarController = MainTabBarController()
            let navigationController = UINavigationController(rootViewController: mainTabBarController)
            navigationController.isNavigationBarHidden = true
            
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        } else {
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}

