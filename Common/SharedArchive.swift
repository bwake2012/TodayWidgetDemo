//
//  GroupObjectSaver.swift
//  TodayWidgetDemo
//
//  Created by Robert Wakefield on 1/10/20.
//

import Foundation

/// Saves and retrieves Codable objects to files in the given app group storage.

enum SharedArchiveError: Error {

    case objectReturnedNotOfType

    var localizedDescription: String {

        switch self {
        case .objectReturnedNotOfType:
            return "The object returned was not of the desired type!"
        }
    }
}

struct SharedArchive: ObjectSharedProtocol {

    fileprivate let sharedData: SharedData

    var appGroupIdentifier: String { return sharedData.appGroupIdentifier }

    var path: String { return sharedData.path }

    init(appGroupIdentifier: String, path: String) {

        self.sharedData = SharedData(appGroupIdentifier: appGroupIdentifier, path: path)
    }

    // Save object in document directory
    func saveObject<T: Encodable>(_ object: T) -> Result<T, Error> {

        let archiver = NSKeyedArchiver(requiringSecureCoding: true)

        do {
            try archiver.encodeEncodable(object, forKey: NSKeyedArchiveRootObjectKey)
            archiver.finishEncoding()
        }
        catch {
            return .failure(error)
        }

        let result = sharedData.writeData(archiver.encodedData)
        switch result {
        case .failure(let error):
            return .failure(error)
        default:
            return .success(object)
        }

    }

    // Get object from document directory
    func getObject<T: Decodable>() -> Result<T, Error> {

        let result = sharedData.readData()

        switch result {

        case .failure(let error):
            return .failure(error)

        case .success(let data):
            do {

                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)

                let something = unarchiver.decodeDecodable(T.self, forKey: NSKeyedArchiveRootObjectKey)
                guard let object = something else {

                    return .failure(SharedArchiveError.objectReturnedNotOfType)
                }

                return .success(object)

            } catch {

                print("error is: \(error.localizedDescription)")
                return .failure(error)
            }
        }
    }

    func metadata() -> Result<[FileAttributeKey: Any], Error> {

        return sharedData.metadata()
    }

    func remove() -> Error? {

        return sharedData.remove()
    }
}
