//
//  HomeViewModel.swift
//  pokeapps
//
//  Created by Faza Azizi on 18/04/25.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class HomeViewModel {
    private let pokemonService: PokemonServiceProtocol
    private let disposeBag = DisposeBag()
    
    let pokemonList = BehaviorRelay<[PokemonDetail]>(value: [])
    let filteredPokemonList = BehaviorRelay<[PokemonDetail]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    let noResults = BehaviorRelay<Bool>(value: false)
    
    let searchQuery = BehaviorRelay<String>(value: "")
    
    private var hasMoreData = true
    private var offset = 0
    private let limit = 10
    
    init(pokemonService: PokemonServiceProtocol = PokemonService()) {
        self.pokemonService = pokemonService
        setupBindings()
    }
    
    private func setupBindings() {
        Observable.combineLatest(pokemonList, searchQuery)
            .subscribe(onNext: { [weak self] (pokemons, query) in
                guard let self = self else { return }
                
                if query.isEmpty {
                    self.filteredPokemonList.accept(pokemons)
                    self.noResults.accept(false)
                } else {
                    let filtered = pokemons.filter {
                        ($0.name ?? "").lowercased().contains(query.lowercased())
                    }
                    self.filteredPokemonList.accept(filtered)
                    self.noResults.accept(filtered.isEmpty)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func fetchPokemonList() {
        guard hasMoreData, !isLoading.value else { return }
        
        isLoading.accept(true)
        
        pokemonService.fetchPokemonList(offset: offset, limit: limit)
            .subscribe(onNext: { [weak self] listResponse in
                guard let self = self else { return }
                
                if let results = listResponse.results {
                    if results.count < self.limit {
                        self.hasMoreData = false
                    } else {
                        self.offset += self.limit
                    }
                    self.fetchAllDetailPokemons(results: results)
                }
            }, onError: { [weak self] error in
                self?.error.onNext(error)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func clearSearch() {
        searchQuery.accept("")
    }
    
    private func fetchAllDetailPokemons(results: [PokemonEntity]) {
        let dispatchGroup = DispatchGroup()
        var tempPokemonDetails: [PokemonDetail] = []
        
        for result in results {
            if let url = result.url {
                dispatchGroup.enter()
                pokemonService.fetchPokemonDetail(url: url)
                    .subscribe(onNext: { pokemonDetail in
                        tempPokemonDetails.append(pokemonDetail)
                        dispatchGroup.leave()
                    }, onError: { error in
                        print("Error fetching Pokémon detail: \(error)")
                        dispatchGroup.leave()
                    })
                    .disposed(by: disposeBag)
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            let currentList = self.pokemonList.value
            let updatedList = currentList + tempPokemonDetails
            self.pokemonList.accept(updatedList)
            
            if self.searchQuery.value.isEmpty {
                self.filteredPokemonList.accept(updatedList)
            } else {
                let query = self.searchQuery.value
                let filtered = updatedList.filter {
                    ($0.name ?? "").lowercased().contains(query.lowercased())
                }
                self.filteredPokemonList.accept(filtered)
                self.noResults.accept(filtered.isEmpty)
            }
            
            self.isLoading.accept(false)
        }
    }
    
    /*
    func goToDetail(from viewController: UIViewController, data: PokemonDetailEntity) {
        let detailVC = PokemonDetailViewController()
        detailVC.viewModel = PokemonDetailViewModel(pokemon: data)
        viewController.navigationController?.pushViewController(detailVC, animated: true)
    }
    */
}
