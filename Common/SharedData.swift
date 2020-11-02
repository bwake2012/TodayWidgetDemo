//
//  SharedContent.swift
//  TodayWidgetDemo
//
//  Created by Robert Wakefield on 1/4/20.
//

import Foundation

typealias SharedResult = Result<Data, Error>

/// Read and write from a shared file in the app group.

struct SharedData {

    var presentedItemURL: URL? {

        return contentURL
    }

    var presentedItemOperationQueue: OperationQueue = OperationQueue()

    let appGroupIdentifier: String
    let path: String

    fileprivate var contentURL: URL {

        var contentURL: URL = FileManager.default.containerURL(
                    forSecurityApplicationGroupIdentifier: appGroupIdentifier
                )!

        contentURL = contentURL.appendingPathComponent(path)

        return contentURL
    }

    init(appGroupIdentifier: String, path: String) {

        self.appGroupIdentifier = appGroupIdentifier
        self.path = path
    }

    /// Read data from the shared file.

    func readData() -> SharedResult {

        var data: Data?
        var coordinatorError: NSError?
        var readError: Error?

        let fileCoordinator = NSFileCoordinator(filePresenter: nil)

        fileCoordinator.coordinate(readingItemAt: contentURL, options: [], error: &coordinatorError) { url in

            do {
                data = try Data(contentsOf: url, options: [])
            }
            catch {
                readError = error
            }
        }

        if let error = coordinatorError {

            return .failure(error)

        } else if let error = readError {

            return .failure(error)

        } else if let data = data {

            return .success(data)
        }

        // we have no data, we didn't get an error, so return empty data
        return .success(Data())
    }

    /// Write Data to the shared file

    func writeData(_ data: Data) -> SharedResult {

        var coordinatorError: NSError?
        var writeError: Error?

        let fileCoordinator = NSFileCoordinator(filePresenter: nil)

        fileCoordinator.coordinate(writingItemAt: contentURL, options: [], error: &coordinatorError) { url in

            do {
                try data.write(to: url, options: [.noFileProtection])
            }
            catch {
                writeError = error
            }
        }

        if let error = coordinatorError {
            return .failure(error)
        } else if let error = writeError {
            return .failure(error)
        }

        return .success(data)
    }

    func metadata() -> Result<[FileAttributeKey: Any], Error> {

        var coordinatorError: NSError?
        var attributesError: Error?

        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        var attributes: [FileAttributeKey: Any] = [:]

        fileCoordinator.coordinate(readingItemAt: contentURL, options: [.immediatelyAvailableMetadataOnly], error: &coordinatorError) { url in

            do {

                attributes = try FileManager.default.attributesOfItem(atPath: url.path)

            } catch {

                attributesError = error
            }
        }

        if let error = coordinatorError {
            return .failure(error)
        } else if let error = attributesError {
            return .failure(error)
        }

        return .success(attributes)
    }

    func remove() -> Error? {

        var coordinatorError: NSError?
        var removeError: Error?

        let fileCoordinator = NSFileCoordinator(filePresenter: nil)

        fileCoordinator.coordinate(writingItemAt: contentURL, options: [], error: &coordinatorError) { url in

            do {
                try FileManager.default.removeItem(at: url)
            }
            catch {
                removeError = error
            }
        }

        if let error = coordinatorError {
            return error
        } else if let error = removeError {
            return error
        }

        return nil
    }
}

