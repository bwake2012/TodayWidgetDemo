//
//  Retriever.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/15/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import Foundation

protocol RetrieverDelegate: class {

    func progressUpdate(percentage: Double)

    func downloadComplete(result: FileDownloadResult)
}

extension RetrieverDelegate {

    func progressUpdate(percentage: Double) {}
    func downloadComplete(result: FileDownloadResult) {}
}

protocol Retriever: class {

    init(with identifier: String, and delegate: RetrieverDelegate)

    func download(from webURL: URL, after delay: TimeInterval)
}
