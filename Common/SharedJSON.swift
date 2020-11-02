//
//  SharedJSON.swift
//  TodayWidgetDemo
//
//  Created by Robert Wakefield on 1/13/20.
//

import UIKit

class SharedJSON: ObjectSharedProtocol {

    fileprivate let sharedData: SharedData

    var appGroupIdentifier: String { return sharedData.appGroupIdentifier }

    var path: String { return sharedData.path }

    required init(appGroupIdentifier: String, path: String) {

        self.sharedData = SharedData(appGroupIdentifier: appGroupIdentifier, path: path)
    }

    func saveObject<T>(_ object: T) -> Result<T, Error> where T : Encodable {

        let archiver = JSONEncoder()

        do {

            let data = try archiver.encode(object)

            let result = sharedData.writeData(data)
            switch result {
            case .failure(let error):
                return .failure(error)
            default:
                return .success(object)
            }
        }
        catch {
            return .failure(error)
        }
    }

    func getObject<T>() -> Result<T, Error> where T : Decodable {

        let result = sharedData.readData()

        switch result {

        case .failure(let error):
            return .failure(error)

        case .success(let data):
            do {

                let unarchiver = JSONDecoder()

                let object = try unarchiver.decode(T.self, from: data)

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
