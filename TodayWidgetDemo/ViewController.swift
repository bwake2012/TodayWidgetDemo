//
//  ViewController.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 1/4/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit

import NotificationCenter

class ViewController: UIViewController {

    fileprivate let sharedJSON = SharedJSON(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonJSON)
    fileprivate let sharedPNG = SharedPNG(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonImage)

    @IBOutlet weak var pokemonImage: UIImageView?
    @IBOutlet weak var pokemonSpecies: UILabel?

    @IBAction func fetchPokemon(_ sender: UIButton) {

        PokeManager.fetchRandomPokemon { success in

            NCWidgetController().setHasContent(
                success,
                forWidgetWithBundleIdentifier: CommonConstants.widgetBundleIdentifier
            )
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerForNotifications()
    }


}

extension ViewController {

    func registerForNotifications() {

        NotificationCenter.default.addObserver(
            forName: .newPokemonFetched,
            object: nil,
            queue: nil) { (notification) in

                print("notification received")
                if let userInfo = notification.userInfo,
                    let pokemon = userInfo["pokemon"] as? Pokemon,
                    let image = userInfo["image"] as? UIImage {

                    print(pokemon.species.name)
                    self.updateWithPokemon(pokemon, and: image)
                }
        }
    }

    func updateWithPokemon(_ pokemon: Pokemon, and image: UIImage) {

        DispatchQueue.main.async {

            self.pokemonSpecies?.text = pokemon.species.name
            self.pokemonImage?.image = image
        }
    }
}

