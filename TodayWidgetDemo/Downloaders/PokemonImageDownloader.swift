//
//  PokemonImageDownloader.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/29/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit
import NotificationCenter

class PokemonImageDownloader: NSObject {

    fileprivate var retriever: BackgroundRetriever?
    fileprivate var fetchCompletion: PokemonCompletion?
    fileprivate var pokemon =
        Pokemon(
            species: Pokemon.Species(name: ""),
            sprites: Pokemon.Sprites(
                backDefault: nil, backShiny: nil, frontDefault: nil, frontShiny: nil
            )
        )

    override init() {

        super.init()

        retriever = BackgroundRetriever(with: "ImageRetriever", and: self)
    }

    func fetchImage(for pokemon: Pokemon, completion: @escaping PokemonCompletion) {

        guard let imageURL = pokemon.sprites.frontDefault else {
            return
        }

        self.fetchCompletion = completion
        self.pokemon = pokemon

        retriever?.download(from: imageURL, after: 0)
    }
}

extension PokemonImageDownloader: RetrieverDelegate {

    func downloadComplete(result: FileDownloadResult) {

        switch result {
        case .failure(let error):
            print("image download error: \(error.localizedDescription)")
            fetchCompletion?(.failure(error))
        case .success(let fileURL):
            let result = loadImage(from: fileURL)
            switch result {
            case .failure(let error):
                print("image load error: \(error.localizedDescription)")
                fetchCompletion?(.failure(error))
            case .success(let image):

                fetchCompletion?(.success((pokemon, image)))
             }
        }
    }
}

extension PokemonImageDownloader {

    func loadImage(from fileURL: URL) -> ImageResult {

        do {
            let data = try Data(contentsOf: fileURL, options: [])

            guard let image = UIImage(data: data) else {

                return .failure(PokemonFetchError.dataToImage)
            }

            return .success(image)

        } catch {

            return .failure(error)
        }
    }
}
