//
//  TodayViewController.swift
//  TodayWidgetDemoWidget
//
//  Created by Bob Wakefield on 1/4/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var todayContent: UITextView!

    let content = TodayWidgetContent()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        todayContent.text = content.text
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        let oldText = todayContent.text
        let newText = content.text

        todayContent.text = newText
        
        completionHandler(newText != oldText ? NCUpdateResult.newData : NCUpdateResult.noData)
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {

        guard let url = URL(string: "todayWidgetDemo://home") else {
            return
        }

        extensionContext?.open(url, completionHandler: nil)
    }
}
