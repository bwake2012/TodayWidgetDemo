//
//  PokeManager.swift
//  ModernBackgroundTasksDemo
//
//  Created by Bob Wakefield on 1/18/20.
//  Copyright © 2020 Bob Wakefield. All rights reserved.
//

import Foundation
import UIKit

class PokeManager {

    private static var retrieverInFlight: Retriever?

    #if DEBUG
    static let foregroundDelay = TimeInterval(0)
    static let backgroundDelay = UIApplication.backgroundFetchIntervalMinimum
    #else
    static let foregroundDelay = TimeInterval(0)
    static let backgroundDelay = TimeInterval(30)
    #endif
    static var delay: TimeInterval {

        if .background == UIApplication.shared.applicationState {
            return backgroundDelay
        } else {
            return foregroundDelay
        }
    }

    static func backgroundPokemon(
            id: Int,
            completionHandler: @escaping (_ pokemon: Pokemon) -> Void) {

        let pokeURL = buildPokemonURL(id: id)

        let retriever =
            BackgroundRetriever(
                from: pokeURL,
                after: delay,
                with: { percentage in

                },
                and: { fileURL in

                    guard
                        let data = try? Data(contentsOf: fileURL, options: [])
                    else { return }

                    let jsonDecoder = JSONDecoder()
                    guard let pokemon = try? jsonDecoder.decode(Pokemon.self, from: data)
                    else { return }

                    completionHandler(pokemon)
                }
            )

        self.retrieverInFlight = retriever
    }

    static func backgroundImage(url imageURL: URL, completionHandler: @escaping (_ image: UIImage) -> Void) {

        let retriever =
            BackgroundRetriever(
                from: imageURL,
                after: 0.0,
                with: { percentage in

                },
                and: { fileURL in

                    guard
                        let data = try? Data(contentsOf: fileURL, options: [])
                    else { return }

                    guard let image = UIImage(data: data) else { return }

                    completionHandler(image)

                    retrieverInFlight = nil
                }
            )
        retrieverInFlight = retriever
    }

     static func buildPokemonURL(id: Int) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "pokeapi.co"
        urlComponents.path = "/api/v2/pokemon/\(id)"
        return urlComponents.url!
    }
}

extension PokeManager {

    static func fetchRandomPokemon(reportSuccess: ((Bool) -> Void)?) {

        let randomPoke = (1...151).randomElement() ?? 1

        PokeManager.backgroundPokemon(id: randomPoke) { pokemon in

            self.processPokemon(pokemon, completion: reportSuccess)
        }
    }

    static func processPokemon(_ pokemon: Pokemon, completion reportSuccess: ((Bool) -> Void)?) {

        _ = self.sharedPNG.remove()
        _ = self.sharedJSON.saveObject(pokemon)

        guard let imageURL = pokemon.sprites.frontDefault else {
            reportSuccess?(true)
            return
        }

        PokeManager.backgroundImage(url: imageURL) { image in

            _ = self.sharedPNG.saveImage(image)

            NotificationCenter.default.post(
                name: .newPokemonFetched,
                object: self,
                userInfo: ["pokemon": pokemon, "image": image]
            )
        }

        reportSuccess?(true)
    }
}
