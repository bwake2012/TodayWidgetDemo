//
//  SharedContent.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 1/4/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import Foundation

class SharedContent: NSObject, NSFilePresenter {

    var presentedItemURL: URL? {

        return contentURL
    }

    var presentedItemOperationQueue: OperationQueue = OperationQueue()

    init(appGroupIdentifier: String) {

        self.appGroupIdentifier = appGroupIdentifier
    }

    fileprivate let appGroupIdentifier: String

    fileprivate var contentURL: URL {

        var contentURL: URL = FileManager.default.containerURL(
                    forSecurityApplicationGroupIdentifier: appGroupIdentifier
                )!

        contentURL = contentURL.appendingPathComponent("demoContent")
        contentURL = contentURL.appendingPathExtension("txt")

        return contentURL
    }

    func readData() -> Data? {

        var data: Data?
        var error: NSError?

        let fileCoordinator: NSFileCoordinator = NSFileCoordinator(filePresenter: self)

        fileCoordinator.coordinate(readingItemAt: contentURL, options: [], error: &error) { url in

            data = try? Data(contentsOf: url, options: [])
        }

        return data
    }

    func writeData(_ data: Data) -> Bool {

        var error: NSError?
        var success = false

        let fileCoordinator: NSFileCoordinator = NSFileCoordinator(filePresenter: self)

        fileCoordinator.coordinate(writingItemAt: contentURL, options: [], error: &error) { url in

            do {

                try data.write(to: contentURL, options: [])
            }
            catch {

                success = false
            }
            success = true
        }

        return success
    }
}

