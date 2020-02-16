//
//  Retriever.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/15/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import Foundation

protocol Retriever: class {

    init(from url: URL, after delay: TimeInterval, with progressUpdate: DownloadProgressUpdateHandler?, and downloadCompletion: DownloadCompletionHandler?)
}
