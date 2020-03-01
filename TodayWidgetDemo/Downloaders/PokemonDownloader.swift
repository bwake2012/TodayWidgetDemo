//
//  PokemonDownloader.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/29/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit

class PokemonDownloader: NSObject {

    fileprivate var retriever: BackgroundRetriever?
    fileprivate let imageDownloader: PokemonImageDownloader

    fileprivate var fetchCompletion: PokemonCompletion?

    init(with imageDownloader: PokemonImageDownloader) {

        self.imageDownloader = imageDownloader

        super.init()

        self.retriever = BackgroundRetriever(with: "PokemonRetriever", and: self)
    }

    func fetchPokemon(from url: URL, completion: @escaping PokemonCompletion) {

        print("fetch pokemon \(url.absoluteString)")

        self.fetchCompletion = completion
        retriever?.download(from: url, after: 0)
    }
}

extension PokemonDownloader: RetrieverDelegate {

    func downloadComplete(result: FileDownloadResult) {

        switch result {
        case .failure(let error):
            print("pokemon download error: \(error.localizedDescription)")
        case .success(let fileURL):
            print("pokemon download success!")
            let result = load(from: fileURL)
            switch result {
            case .failure(let error):
                print("parse error: \(error.localizedDescription)")
            case .success(let pokemon):

                guard let fetchCompletion = self.fetchCompletion else { return }

                imageDownloader.fetchImage(for: pokemon, completion: fetchCompletion)
            }
        }
    }
}

extension PokemonDownloader {

    func load(from fileURL: URL) -> PokemonResult {

        do {
            let data = try Data(contentsOf: fileURL, options: [])

            let jsonDecoder = JSONDecoder()
            let pokemon = try jsonDecoder.decode(Pokemon.self, from: data)

            return .success(pokemon)

        } catch {
            print("Pokemon JSON: \(error.localizedDescription)")
            return .failure(error)
        }
    }

}
