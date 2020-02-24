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

    fileprivate static let sharedJSON = SharedJSON(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonJSON)
    fileprivate static let sharedPNG = SharedPNG(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonImage)

    @IBOutlet weak var appStatus: UILabel?
    @IBOutlet weak var pokemonImage: UIImageView?
    @IBOutlet weak var pokemonSpecies: UILabel?

    @IBAction func fetchPokemon(_ sender: UIButton) {

        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        appDelegate?.fetchRandomPokemon { success in

            print("Pokemon \(success ? "" : "not ")fetched!")
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerForNotifications()

        let result: Result<Pokemon, Error> = Self.sharedJSON.getObject()
        switch result {
        case .failure(let error):
            print("Pokemon error: \(error.localizedDescription)")
        case .success(let pokemon):
            let imageResult = Self.sharedPNG.getImage()
            switch imageResult {
            case .failure(let error):
                print("image error: \(error.localizedDescription)")
            case .success(let image):
                updateWithPokemon(pokemon, and: image)
            }
        }

        appStatus?.text = "Background Refresh Status: " + UIApplication.shared.backgroundRefreshStatus.description
    }
}

extension ViewController {

    func registerForNotifications() {

        NotificationCenter.default.addObserver(
            forName: .newPokemonFetched,
            object: nil,
            queue: nil) { (notification) in

                DispatchQueue.main.async {

                    print("notification received")
                    if let userInfo = notification.userInfo,
                        let pokemon = userInfo["pokemon"] as? Pokemon,
                        let image = userInfo["image"] as? UIImage {

                        print(pokemon.species.name)
                        self.updateWithPokemon(pokemon, and: image)
                    }
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

extension UIBackgroundRefreshStatus {

    var description: String {

        switch self {

        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .available:
            return "available"
        @unknown default:
            return "unexpected status: \(self.rawValue)"
        }
    }
}
