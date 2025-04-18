//
//  PokemonService.swift
//  pokeapps
//
//  Created by Faza Azizi on 18/04/25.
//

import Foundation
import RxSwift

protocol PokemonServiceProtocol {
    func fetchPokemonList(offset: Int, limit: Int) -> Observable<PokemonResponse>
    func fetchPokemonDetail(url: String) -> Observable<PokemonDetail>
    func fetchPokemonDetailById(id: Int) -> Observable<PokemonDetail>
    func searchPokemon(name: String) -> Observable<PokemonDetail>
}

// Implementation of the protocol
class PokemonService: PokemonServiceProtocol {
    private let networkManager = NetworkManager.shared
    
    func fetchPokemonList(offset: Int, limit: Int) -> Observable<PokemonResponse> {
        let url = "\(Constants.baseURL)/pokemon?offset=\(offset)&limit=\(limit)"
        return networkManager.request(url)
    }
    
    func fetchPokemonDetail(url: String) -> Observable<PokemonDetail> {
        return networkManager.request(url)
    }
    
    func fetchPokemonDetailById(id: Int) -> Observable<PokemonDetail> {
        let url = "\(Constants.baseURL)/pokemon/\(id)"
        return networkManager.request(url)
    }
    
    func searchPokemon(name: String) -> Observable<PokemonDetail> {
        let url = "\(Constants.baseURL)/pokemon/\(name.lowercased())"
        return networkManager.request(url)
    }
}
