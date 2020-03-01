//
//  AppErrors.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/29/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import Foundation

enum PokemonFetchError: Error {
    case dataToImage
    case jsonToPokemon

    var localizedDescription: String {

        switch self {
        case .dataToImage:
            return "Unable to convert data to image."
        case .jsonToPokemon:
            return "Unable to load Pokemon from json."
        }
    }
}

