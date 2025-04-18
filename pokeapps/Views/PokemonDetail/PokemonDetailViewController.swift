//
//  PokemonDetailViewController.swift
//  pokeapps
//
//  Created by Faza Azizi on 18/04/25.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

class PokemonDetailViewController: UIViewController {
    
    @IBOutlet weak var namePokemonLbl: UILabel!
    @IBOutlet weak var containerVw: UIView!
    @IBOutlet weak var backImgVw: UIImageView!
    @IBOutlet weak var pokemonImgVw: UIImageView!
    @IBOutlet weak var abilityTableVw: UITableView!
    @IBOutlet weak var typeTableVw: UITableView!
    @IBOutlet weak var statsTableVw: UITableView!
    @IBOutlet weak var moveTableVw: UITableView!
    @IBOutlet weak var containerLoadMoreVw: UIView!
    
    @IBOutlet weak var abilityHeighConstraint: NSLayoutConstraint!
    @IBOutlet weak var moveHeighConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeHeighConstraint: NSLayoutConstraint!
    @IBOutlet weak var statHeighConstraint: NSLayoutConstraint!
    
    var viewModel: PokemonDetailViewModel!
    var pokemonId: Int = 0
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension PokemonDetailViewController {
    private func setupView() {
        setupTableViews()
        setupActions()
        setupUI()
        updateConstraints()
    }
    
    private func setupUI() {
        containerVw.layer.cornerRadius = 24
        containerVw.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerVw.clipsToBounds = true
        
        containerLoadMoreVw.layer.cornerRadius = 8
        containerLoadMoreVw.clipsToBounds = true
        
        view.setBackground(type: viewModel.getBackgroundColorForType())
        
        namePokemonLbl.text = viewModel.getPokemonName()
        
        if let imageUrl = viewModel.getPokemonImageUrl() {
            pokemonImgVw.loadImageUrl(imageUrl)
        }
    }
    
    private func updateConstraints() {
        let heights = viewModel.calculateHeights()
        abilityHeighConstraint.constant = heights.abilities
        moveHeighConstraint.constant = heights.moves
        typeHeighConstraint.constant = heights.types
        statHeighConstraint.constant = heights.stats
    }
    
    private func setupTableViews() {
        statsTableVw.dataSource = self
        statsTableVw.delegate = self
        statsTableVw.register(StatTVC.nib, forCellReuseIdentifier: StatTVC.identifier)
        
        moveTableVw.dataSource = self
        moveTableVw.delegate = self
        moveTableVw.register(MoveTVC.nib, forCellReuseIdentifier: MoveTVC.identifier)
        
        abilityTableVw.dataSource = self
        abilityTableVw.delegate = self
        abilityTableVw.register(MoveTVC.nib, forCellReuseIdentifier: MoveTVC.identifier)
        
        typeTableVw.dataSource = self
        typeTableVw.delegate = self
        typeTableVw.register(TypeTVC.nib, forCellReuseIdentifier: TypeTVC.identifier)
    }
    
    private func bindViewModel() {
        viewModel.pokemonDetail
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.setupUI()
                self.updateConstraints()
                self.reloadAllTableViews()
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func reloadAllTableViews() {
        abilityTableVw.reloadData()
        typeTableVw.reloadData()
        statsTableVw.reloadData()
        moveTableVw.reloadData()
    }
    
    private func setupActions() {
        let backTapGesture = UITapGestureRecognizer()
        backImgVw.addGestureRecognizer(backTapGesture)
        backImgVw.isUserInteractionEnabled = true
        
        backTapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.goToList(from: self)
            })
            .disposed(by: disposeBag)
        
        let loadMoreTapGesture = UITapGestureRecognizer()
        containerLoadMoreVw.addGestureRecognizer(loadMoreTapGesture)
        containerLoadMoreVw.isUserInteractionEnabled = true
        
        loadMoreTapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let moves = self.viewModel.getMoves()
                self.viewModel.showPopupMove(from: self, data: moves)
            })
            .disposed(by: disposeBag)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PokemonDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case typeTableVw:
            return viewModel.getTypes().count
        case abilityTableVw:
            return viewModel.getAbilities().count
        case statsTableVw:
            return viewModel.getStats().count
        case moveTableVw:
            return viewModel.getMovesForDisplay().count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case typeTableVw:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TypeTVC.identifier, for: indexPath) as? TypeTVC else {
                return UITableViewCell()
            }
            let types = viewModel.getTypes()
            cell.configureCell(data: types[indexPath.row])
            return cell
            
        case abilityTableVw:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MoveTVC.identifier, for: indexPath) as? MoveTVC else {
                return UITableViewCell()
            }
            let abilities = viewModel.getAbilities()
            cell.configureCellAbility(data: abilities[indexPath.row])
            return cell
            
        case statsTableVw:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StatTVC.identifier, for: indexPath) as? StatTVC else {
                return UITableViewCell()
            }
            let stats = viewModel.getStats()
            cell.configureCell(data: stats[indexPath.row])
            return cell
            
        case moveTableVw:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MoveTVC.identifier, for: indexPath) as? MoveTVC else {
                return UITableViewCell()
            }
            let moves = viewModel.getMovesForDisplay()
            cell.configureCell(data: moves[indexPath.row])
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case statsTableVw:
            return 40
        default:
            return 50
        }
    }
}
