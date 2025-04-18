//
//  HomeViewController.swift
//  pokeapps
//
//  Created by Faza Azizi on 18/04/25.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD
import XLPagerTabStrip

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    private var footerView: UIView?
    private var isLoadingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        viewModel.fetchPokemonList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension HomeViewController {
    private func setupView() {
        setupTableView()
        setupSearchBar()
        setupLoadingFooter()
    }
    
    private func setupTableView() {
        tableView.register(PokemonListTableViewCell.nib, forCellReuseIdentifier: PokemonListTableViewCell.identifier)
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Search Pokemon"
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        
        searchBar.returnKeyType = .search
    }
    
    private func setupLoadingFooter() {
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = CGPoint(x: footerView!.bounds.midX, y: footerView!.bounds.midY)
        activityIndicator.startAnimating()
        footerView?.addSubview(activityIndicator)
        footerView?.isHidden = true
        tableView.tableFooterView = footerView
    }
    
    private func bindViewModel() {
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)
        
        viewModel.filteredPokemonList
            .bind(to: tableView.rx.items(cellIdentifier: PokemonListTableViewCell.identifier, cellType: PokemonListTableViewCell.self)) { (row, pokemon, cell) in
                cell.configureCell(data: pokemon)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(PokemonDetail.self)
            .subscribe(onNext: { [weak self] pokemon in
                guard let self = self else { return }
//                let detailVC = PokemonDetailViewController(nibName: "PokemonDetailViewController", bundle: nil)
//                detailVC.pokemonId = pokemon.id ?? 0
//                self.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    if self.viewModel.pokemonList.value.isEmpty {
                        MBProgressHUD.showAdded(to: self.view, animated: true)
                    } else {
                        self.isLoadingMore = true
                        self.footerView?.isHidden = false
                    }
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.isLoadingMore = false
                    self.footerView?.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.noResults
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] noResults in
                if noResults {
                    self?.showNoResultsView()
                } else {
                    self?.hideNoResultsView()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showNoResultsView() {
        if tableView.backgroundView == nil {
            let noResultsLabel = UILabel()
            noResultsLabel.text = "No Pokemon found"
            noResultsLabel.textAlignment = .center
            noResultsLabel.textColor = .gray
            tableView.backgroundView = noResultsLabel
        }
        tableView.separatorStyle = .none
    }
    
    private func hideNoResultsView() {
        tableView.backgroundView = nil
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex &&
           indexPath.row == lastRowIndex &&
           !isLoadingMore &&
           viewModel.searchQuery.value.isEmpty {
            viewModel.fetchPokemonList()
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.clearSearch()
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if viewModel.searchQuery.value.isEmpty {
            let position = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.frame.size.height
            
            let threshold = contentHeight - scrollViewHeight * 1.2
            
            if position > threshold && !isLoadingMore && contentHeight > 0 {
                viewModel.fetchPokemonList()
            }
        }
        
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
}

extension HomeViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Home")
    }
}
