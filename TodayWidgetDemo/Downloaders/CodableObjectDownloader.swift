//
//  CodableObjectDownloader.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/29/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit

class CodableObjectDownloader<T: Decodable>: NSObject {

    typealias ObjectResult = Result<T, Error>
    typealias ObjectCompletion = (ObjectResult) -> Void

    fileprivate var retriever: Retriever?

    fileprivate var fetchCompletion: ObjectCompletion?

    override init() {

        super.init()

        let typeName = String(describing: T.self)
        self.retriever = BackgroundRetriever(with: typeName + " Retriever", and: self)
    }

    func fetchObject(from url: URL, completion: @escaping ObjectCompletion) {

        print("fetch object \(url.absoluteString)")

        self.fetchCompletion = completion
        retriever?.download(from: url, after: 0)
    }
}

extension CodableObjectDownloader: RetrieverDelegate {

    func downloadComplete(result: FileDownloadResult) {

        switch result {
        case .failure(let error):
            print("object download error: \(error.localizedDescription)")
        case .success(let fileURL):
            print("object download success!")
            let result = load(from: fileURL)

            fetchCompletion?(result)
        }
    }
}

extension CodableObjectDownloader {

    func load(from fileURL: URL) -> ObjectResult {

        do {
            let data = try Data(contentsOf: fileURL, options: [])

            let jsonDecoder = JSONDecoder()
            let object = try jsonDecoder.decode(T.self, from: data)

            return .success(object)

        } catch {
            print("Object JSON: \(error.localizedDescription)")
            return .failure(error)
        }
    }

}
