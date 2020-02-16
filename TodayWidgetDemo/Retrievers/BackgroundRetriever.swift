//
//  PokemonBackgroundRetriever.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/9/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit

#if DEBUG
fileprivate let downloadInterval: TimeInterval = 30
#else
fileprivate let downloadInterval: TimeInterval = 60 * 60
#endif

class BackgroundRetriever: NSObject, Retriever {

    let progressUpdateHandler: DownloadProgressUpdateHandler?
    let downloadCompletionHandler: DownloadCompletionHandler?
    
    var backgroundURLSession: URLSession {
        let config = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    required init(
            from url: URL,
            after delay: TimeInterval,
            with progressUpdate: DownloadProgressUpdateHandler?,
            and downloadCompletion: DownloadCompletionHandler?) {

        self.progressUpdateHandler = progressUpdate
        self.downloadCompletionHandler = downloadCompletion

        super.init()

        backgroundDownload(after: delay, from: url)
    }

    func backgroundDownload(after delay: TimeInterval, from webURL: URL) {

        let task = backgroundURLSession.downloadTask(with: webURL)

        task.earliestBeginDate = Date().addingTimeInterval(delay)
        task.countOfBytesClientExpectsToSend = 1024
        task.countOfBytesClientExpectsToReceive = 8192

        task.resume()
    }
}

extension BackgroundRetriever: URLSessionDelegate {

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {

        guard
            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let backgroundCompletionHandler = appDelegate.backgroundCompletionHandler
        else { return }

        appDelegate.backgroundCompletionHandler = nil
        DispatchQueue.main.async {

            backgroundCompletionHandler()
        }
    }
}

extension BackgroundRetriever: URLSessionDownloadDelegate {

    func urlSession(
            _ session: URLSession,
            downloadTask: URLSessionDownloadTask,
            didFinishDownloadingTo fileURL: URL) {

        downloadCompletionHandler?(fileURL)

        session.finishTasksAndInvalidate()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else {
            return
        }

        let progress: Double = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)

        print("Download progress: \(progress)")

        DispatchQueue.main.async {
            self.progressUpdateHandler?(progress)
        }
    }
}
