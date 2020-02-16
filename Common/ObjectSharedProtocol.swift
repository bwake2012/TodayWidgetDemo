//
//  SharedObjectProtocol.swift
//  TodayWidgetDemo
//
//  Created by Robert Wakefield on 1/13/20.
//  Copyright © 2020 State Farm. All rights reserved.
//

import Foundation

protocol ObjectSharedProtocol {

    var appGroupIdentifier: String { get }
    var path: String { get }

    init(appGroupIdentifier: String, path: String)

    func saveObject<T: Encodable>(_ object: T) -> Result<T, Error>
    func getObject<T: Decodable>() -> Result<T, Error>

    func metadata() -> Result<[FileAttributeKey: Any], Error>

    func remove() -> Error?
}
