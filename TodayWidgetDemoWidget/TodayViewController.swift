//
//  TodayViewController.swift
//  TodayWidgetDemoWidget
//
//  Created by Bob Wakefield on 1/4/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var pokemonSpeciesName: UILabel?
    @IBOutlet weak var pokemonImage: UIImageView?

    let sharedJSON = SharedJSON(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonJSON)
    let sharedPNG = SharedPNG(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonImage)

    @IBAction func didTap(_ sender: UITapGestureRecognizer) {

        guard let url = URL(string: "todayWidgetDemo://home") else {
            return
        }

        extensionContext?.open(url, completionHandler: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.


    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        let oldText = pokemonSpeciesName?.text ?? ""
        var completionResult = false

        let result: Result<Pokemon, Error> = sharedJSON.getObject()
        switch result {
        case .failure(_):
            break
        case .success(let pokemon):
            pokemonSpeciesName?.text = pokemon.species.name
            completionResult = oldText != pokemon.species.name
            let result = sharedPNG.getImage()
            switch result {
            case .failure(_):
                break
            case .success(let image):
                pokemonImage?.image = image
            }
        }

        completionHandler(completionResult ? NCUpdateResult.newData : NCUpdateResult.noData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {

        switch activeDisplayMode {

        case .compact:
            preferredContentSize = maxSize
        case .expanded:
            preferredContentSize = maxSize
        @unknown default:
            fatalError("Unexpected today widget active display mode")
        }
    }
}
