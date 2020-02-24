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
// as often as possible, for debugging
fileprivate let backgroundFetchInterval = UIApplication.backgroundFetchIntervalMinimum
#else
// every 5 minutes
fileprivate let backgroundFetchInterval = TimeInterval(integerLiteral: 60 * 5)
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    typealias DownloadResult = Result<URL, Error>
    typealias DownloadCompletion = (DownloadResult) -> Void
    typealias ImageResult = Result<UIImage, Error>
    typealias ImageCompletion = (ImageResult) -> Void
    typealias PokemonResult = Result<Pokemon, Error>
    typealias PokemonCompletion = (PokemonResult) -> Void

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

    var backgroundCompletionHandler: (() -> Void)?

    var window: UIWindow?

    fileprivate let sharedJSON = SharedJSON(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonJSON)
    fileprivate let sharedPNG = SharedPNG(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonImage)

    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {

        // Override point for customization after application launch.
        application.setMinimumBackgroundFetchInterval(backgroundFetchInterval)

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        print("Entering Background")
    }

    func application(
            _ application: UIApplication,
            performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        fetchRandomPokemon() { success in

            completionHandler(success ? .newData : .failed)
        }
    }
}

extension AppDelegate {

    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {

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
        print("Background Fetch \(randomPoke) started...")

        fetchPokemon(id: randomPoke, completionHandler: completionHandler)

        print("Background Fetch returns...")
    }

    func fetchPokemon(id pokemonID: Int, completionHandler: @escaping (Bool) -> Void) {

        let url = buildURL(id: pokemonID)

        fetchPokemon(from: url) { result in

            switch result {
            case .failure(let error):
                let errorDescription = error.localizedDescription
                print("Background fetch failed: \(errorDescription)")
                completionHandler(false)
            case .success(let pokemon):
                guard let imageURL = pokemon.sprites.frontDefault else {
                    completionHandler(false)
                    return
                }

                _ = self.sharedPNG.remove()
                _ = self.sharedJSON.saveObject(pokemon)

                self.fetchImage(from: imageURL) { result in

                    switch result {
                    case .failure(_):
                        completionHandler(false)
                        return
                    case .success(let image):
                        _ = self.sharedPNG.saveImage(image)

                        DispatchQueue.main.async {

                            guard
                                .background != UIApplication.shared.applicationState
                                else { return }

                            NotificationCenter.default.post(
                                name: .newPokemonFetched,
                                object: self,
                                userInfo: ["pokemon": pokemon, "image": image]
                            )
                        }
                        completionHandler(true)
                    }
                }
            }
        }
    }

    func fetchPokemon(from url: URL, completion: @escaping PokemonCompletion) {

        fetchFile(from: url) { result in

            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let fileURL):
                completion(self.loadPokemon(from: fileURL))
            }

        }
    }

    func loadPokemon(from url: URL) -> PokemonResult {

        do {
            let data = try Data(contentsOf: url, options: [])

            let jsonDecoder = JSONDecoder()
            let pokemon = try jsonDecoder.decode(Pokemon.self, from: data)

            return .success(pokemon)

        } catch {
            print("Pokemon JSON: \(error.localizedDescription)")
            return .failure(error)
        }
    }

    func fetchImage(from url: URL, completion: @escaping ImageCompletion) {

        fetchFile(from: url) { result in

            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let fileURL):
                completion(self.loadImage(from: fileURL))
            }
        }
    }

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

    func display(_ pokemon: Pokemon?) {

        guard let pokemon = pokemon else { return }

        DispatchQueue.main.async {

            _ = self.sharedPNG.remove()
            _ = self.sharedJSON.saveObject(pokemon)
        }
    }

    func fetchFile(from url: URL, with completion: @escaping DownloadCompletion) {

        let session = URLSession.shared
        let task = session.downloadTask(with: url) { fileURL, response, error in

            if let fileURL = fileURL {

                completion(.success(fileURL))

            } else if let error = error {

                completion(.failure(error))

            }
        }
        task.resume()
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
