//
//  AppDelegate.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 1/4/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit
import BackgroundTasks
import NotificationCenter

#if DEBUG
// every 2 minutes, for debugging
fileprivate let backgroundFetchInterval = TimeInterval(integerLiteral: 60 * 2)
#else
// every 30 minutes
fileprivate let backgroundFetchInterval = TimeInterval(integerLiteral: 60 * 30)
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    fileprivate let sharedJSON = SharedJSON(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonJSON)
    fileprivate let sharedPNG = SharedPNG(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonImage)

    var backgroundCompletionHandler: (() -> Void)?

    var window: UIWindow?

    var pokemonDownloader: CodableObjectDownloader<Pokemon>?
    var pokemonImageDownloader: ImageDownloader?

    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {

        // Override point for customization after application launch.
        self.pokemonImageDownloader = ImageDownloader()
        self.pokemonDownloader = CodableObjectDownloader()

        application.setMinimumBackgroundFetchInterval(backgroundFetchInterval)
        print("Background fetch interval: \(backgroundFetchInterval) seconds.")

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        print("Will Enter Foreground")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        print("Did Enter Background")
    }

    func application(
            _ application: UIApplication,
            performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        print("Background fetch begins")
        fetchRandomPokemon() { success in

            completionHandler(success ? .newData : .failed)

            print("background fetch \(success ? "succeeded" : "failed")")
        }
    }
}

extension AppDelegate {

    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {

        print("Handle events for background URL session: \(identifier)")
        backgroundCompletionHandler = completionHandler
    }
}

extension Notification.Name {

    static let newPokemonFetched = Notification.Name("net.cockleburr.ModernBackgroundTasksDemo.pokemonFetched")
}

extension AppDelegate {

    func buildURL(id: Int) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "pokeapi.co"
        urlComponents.path = "/api/v2/pokemon/\(id)"
        return urlComponents.url!
    }

    func fetchRandomPokemon(completionHandler: @escaping (Bool) -> Void) {

        let randomPoke = (1...151).randomElement() ?? 1

        pokemonDownloader?.fetchObject(from: buildURL(id: randomPoke)) { result in

            var success = false
            switch result {
            case .failure(let error):
                print("pokemon fetch error: \(error.localizedDescription)")
            case .success(let pokemon):
                _ = self.sharedPNG.remove()
                _ = self.sharedJSON.saveObject(pokemon)

                guard let imageURL = pokemon.sprites.frontDefault else {
                    completionHandler(false)
                    break
                }

                self.pokemonImageDownloader?.fetchImage(from: imageURL) { result in

                    switch result {
                    case .failure(let error):
                        print("image fetch error: \(error.localizedDescription)")
                    case .success(let image):
                        _ = self.sharedPNG.saveImage(image)

                        let userInfo: [String: Any] = ["pokemon": pokemon, "image": image]

                        NotificationCenter.default.post(name: .newPokemonFetched, object: nil, userInfo: userInfo)

                        print("Pokemon \(pokemon.species.name) fetched!")
                        success = true
                    }

                    NCWidgetController().setHasContent(
                        success,
                        forWidgetWithBundleIdentifier: CommonConstants.widgetBundleIdentifier
                    )

                    completionHandler(success)
                }
            }
        }
    }
}

extension AppDelegate {

    // MARK: UISceneSession Lifecycle

    @available (iOS 13, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available (iOS 13, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
