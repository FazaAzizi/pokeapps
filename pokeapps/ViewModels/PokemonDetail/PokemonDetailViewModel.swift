//
//  PokemonDetailViewModel.swift
//  pokeapps
//
//  Created by Faza Azizi on 18/04/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class PokemonDetailViewModel {
    
    private let disposeBag = DisposeBag()
    
    let pokemonDetail = BehaviorRelay<PokemonDetail?>(value: nil)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    
    init(pokemonDetail: PokemonDetail? = nil) {
        self.pokemonDetail.accept(pokemonDetail)
    }
    
    func goToList(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
    
    func showPopupMove(from viewController: UIViewController, data: [Move]) {
        let popupMoves = PopupMovesView(nibName: String(describing: PopupMovesView.self), bundle: nil)
        popupMoves.modalPresentationStyle = .overFullScreen
        popupMoves.modalTransitionStyle = .crossDissolve
        popupMoves.data = data
        viewController.present(popupMoves, animated: true)
    }
    
    func getBackgroundColorForType() -> String {
        guard let type = pokemonDetail.value?.types?.first?.type?.name else {
            return ""
        }
        
        return type
    }
    
    func getPokemonImageUrl() -> String? {
        return pokemonDetail.value?.sprites?.frontDefault
    }
    
    func getPokemonName() -> String {
        return pokemonDetail.value?.name?.capitalized ?? "Unknown Pokemon"
    }
    
    func getAbilities() -> [Ability] {
        return pokemonDetail.value?.abilities ?? []
    }
    
    func getTypes() -> [TypeElement] {
        return pokemonDetail.value?.types ?? []
    }
    
    func getStats() -> [Stat] {
        return pokemonDetail.value?.stats ?? []
    }
    
    func getMoves() -> [Move] {
        return pokemonDetail.value?.moves ?? []
    }
    
    func getMovesForDisplay() -> [Move] {
        let allMoves = getMoves()
        return allMoves.count > 3 ? Array(allMoves.prefix(3)) : allMoves
    }
    
    func shouldShowLoadMoreMoves() -> Bool {
        return (pokemonDetail.value?.moves?.count ?? 0) > 3
    }
    
    func calculateHeights() -> (abilities: CGFloat, moves: CGFloat, types: CGFloat, stats: CGFloat) {
        let abilities = CGFloat((pokemonDetail.value?.abilities?.count ?? 0) * 50)
        let movesCount = min(pokemonDetail.value?.moves?.count ?? 0, 3)
        let moves = CGFloat(movesCount * 50)
        let types = CGFloat((pokemonDetail.value?.types?.count ?? 0) * 50)
        let stats = CGFloat((pokemonDetail.value?.stats?.count ?? 0) * 40)
        
        return (abilities, moves, types, stats)
    }
}
