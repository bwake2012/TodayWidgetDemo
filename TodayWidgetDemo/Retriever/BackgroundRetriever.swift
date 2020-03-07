//
//  PokemonBackgroundRetriever.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/9/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit

class BackgroundRetriever: NSObject, Retriever {

    weak var delegate: RetrieverDelegate?

    private var backgroundURLSession: URLSession?

    required init(with identifier: String, and delegate: RetrieverDelegate) {

        let config = URLSessionConfiguration.background(withIdentifier: identifier)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true

        self.delegate = delegate

        super.init()

        backgroundURLSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    func download(
        from webURL: URL,
        after delay: TimeInterval) {

        guard let task = backgroundURLSession?.downloadTask(with: webURL) else {
            preconditionFailure("backgroundURLSession is nil!")
        }

        //        task.earliestBeginDate = Date().addingTimeInterval(delay)
        task.countOfBytesClientExpectsToSend = 256
        task.countOfBytesClientExpectsToReceive = 2048

        task.resume()
    }
}

extension BackgroundRetriever: URLSessionDelegate {

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {

        DispatchQueue.main.async {

            guard
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let backgroundCompletionHandler = appDelegate.backgroundCompletionHandler
            else {
                return
            }

            appDelegate.backgroundCompletionHandler = nil

            backgroundCompletionHandler()
        }
    }
}

extension BackgroundRetriever: URLSessionDownloadDelegate {

    func urlSession(
            _ session: URLSession,
            downloadTask: URLSessionDownloadTask,
            didFinishDownloadingTo fileURL: URL) {

        delegate?.downloadComplete(result: .success(fileURL))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        guard let error = error else { return }
        print("download error: \(error.localizedDescription)")
        delegate?.downloadComplete(result: .failure(error))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else {
            return
        }

        var progress: Double = 0
        if 0 != totalBytesExpectedToWrite {

            progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        }

        print("Download progress: \(progress)")

        if let delegate = delegate {

            DispatchQueue.main.async {

                delegate.progressUpdate(percentage: progress)
            }
        }
    }
}
