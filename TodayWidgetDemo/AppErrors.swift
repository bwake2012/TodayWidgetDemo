//
//  AppErrors.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/29/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import Foundation

enum ObjectFetchError: Error {

    case dataToImage
    case jsonToObject

    var localizedDescription: String {

        switch self {
        case .dataToImage:
            return "Unable to convert data to image."
        case .jsonToObject:
            return "Unable to load Object from json."
        }
    }
}

