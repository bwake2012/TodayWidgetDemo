//
//  ImageDownloader.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/29/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit
import NotificationCenter

class ImageDownloader: NSObject {

    typealias ImageResult = Result<UIImage, Error>
    typealias ImageCompletion = (ImageResult) -> Void

    fileprivate var retriever: Retriever?
    fileprivate var fetchCompletion: ImageCompletion?

    override init() {

        super.init()

        retriever = BackgroundRetriever(with: "ImageRetriever", and: self)
    }

    func fetchImage(from imageURL: URL, completion: @escaping ImageCompletion) {

        self.fetchCompletion = completion

        retriever?.download(from: imageURL, after: 0)
    }
}

extension ImageDownloader: RetrieverDelegate {

    func downloadComplete(result: FileDownloadResult) {

        switch result {
        case .failure(let error):
            print("image download error: \(error.localizedDescription)")
            fetchCompletion?(.failure(error))
        case .success(let fileURL):
            let result = loadImage(from: fileURL)

            fetchCompletion?(result)
        }
    }
}

extension ImageDownloader {

    func loadImage(from fileURL: URL) -> ImageResult {

        do {
            let data = try Data(contentsOf: fileURL, options: [])

            guard let image = UIImage(data: data) else {

                return .failure(ObjectFetchError.dataToImage)
            }

            return .success(image)

        } catch {

            return .failure(error)
        }
    }
}
