//
//  PokemonModel.swift
//  pokeapps
//
//  Created by Faza Azizi on 18/04/25.
//

import Foundation

struct PokemonResponse: Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [PokemonEntity]?
}

struct PokemonEntity: Codable {
    let name: String?
    let url: String?
}

