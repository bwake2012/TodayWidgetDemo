//
//  TodayWidgetContent.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 1/4/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import Foundation

struct TodayWidgetContent {

    static let appGroupIdentifier = "group.net.cockleburr.TodayWidgetDemo"

    fileprivate let sharedContent = SharedContent(appGroupIdentifier: Self.appGroupIdentifier)

    var text: String {

        get {

            return readContent()
        }

        set {

            _ = writeContent(newValue)
        }
    }

    private func readContent() -> String {

        guard let data = sharedContent.readData() else {

            return ""
        }

        return String(data: data, encoding: .utf8) ?? ""
    }

    private func writeContent(_ content: String) -> Bool {

        guard let data = content.data(using: .utf8) else {
            return false
        }

        return sharedContent.writeData(data)
    }
}
