//
//  AppDelegate.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 1/4/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit
import BackgroundTasks

#if DEBUG
// as often as possible, for debugging
fileprivate let backgroundFetchInterval = UIApplication.backgroundFetchIntervalMinimum
#else
// every 5 minutes
fileprivate let backgroundFetchInterval = TimeInterval(integerLiteral: 60 * 5)
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var backgroundCompletionHandler: (() -> Void)?

    var window: UIWindow?

    fileprivate let sharedJSON = SharedJSON(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonJSON)
    fileprivate let sharedPNG = SharedPNG(appGroupIdentifier: CommonConstants.appGroupIdentifier, path: CommonConstants.demoContentPokemonImage)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.
        application.setMinimumBackgroundFetchInterval(1800)

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {


    }

    func application(
            _ application: UIApplication,
            performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    }

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

