//
//  PopupMoves.swift
//  pokemon
//
//  Created by Faza Azizi on 18/04/25.
//

import UIKit
import RxSwift

class PopupMovesView: UIViewController {
    @IBOutlet weak var containerVw: UIView!
    @IBOutlet weak var closeImgVw: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()

    var data: [Move] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

extension PopupMovesView {
    private func setupView() {
        containerVw.makeCornerRadius(16)
        setupAction()
        setupTableView()
    }
    
    private func setupAction() {
        
        let backTapGesture = UITapGestureRecognizer()
        closeImgVw.addGestureRecognizer(backTapGesture)
        closeImgVw.isUserInteractionEnabled = true
        
        backTapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(MoveTVC.nib, forCellReuseIdentifier: MoveTVC.identifier)
        self.tableView.reloadData()
    }
}

extension PopupMovesView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoveTVC.identifier, for: indexPath) as? MoveTVC
        else { return UITableViewCell() }
        
        cell.configureCell(data: data[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
