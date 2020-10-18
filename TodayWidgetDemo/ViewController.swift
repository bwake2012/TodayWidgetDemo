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

    fileprivate lazy var dateTimeFormatter: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        return formatter
    }()

    @IBOutlet weak var appStatus: UILabel?
    @IBOutlet weak var pokemonImage: UIImageView?
    @IBOutlet weak var pokemonSpecies: UILabel?
    @IBOutlet weak var timestamp: UILabel!

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

        displayFromFiles()

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

                        self.displayWithPokemon(pokemon, image: image, and: Date())
                    }
                }
        }
    }

    func displayWithPokemon(_ pokemon: Pokemon?, image: UIImage?, and date: Date?) {

        DispatchQueue.main.async {

            self.pokemonSpecies?.text = pokemon?.species.name.capitalized ?? "Pokemon not retrieved."
            self.pokemonImage?.image = image
            if let date = date {
                self.timestamp?.text = self.dateTimeFormatter.string(from: date)
            } else {
                self.timestamp?.text = nil
            }
        }
    }

    func displayFromFiles() {

        displayWithPokemon(
            getSharedPokemon(),
            image: getSharedImage(),
            and: getSharedDate()
        )
    }

    func getSharedPokemon() -> Pokemon? {

        let result: Result<Pokemon, Error> = Self.sharedJSON.getObject()
        switch result {
        case .failure(let error):
            print("Pokemon error: \(error.localizedDescription)")
            return nil
        case .success(let pokemon):
            return pokemon
        }
    }

    func getSharedImage() -> UIImage? {
        let imageResult = Self.sharedPNG.getImage()
        switch imageResult {
        case .failure(let error):
            print("image error: \(error.localizedDescription)")
            return nil
        case .success(let image):
            return image
        }
    }

    func getSharedDate() -> Date? {

        let result = Self.sharedJSON.metadata()
        switch result {
        case .failure(let error):
            print("Metadata error: \(error.localizedDescription)")
            return nil
        case .success(let metadata):
            return metadata[.modificationDate] as? Date
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
