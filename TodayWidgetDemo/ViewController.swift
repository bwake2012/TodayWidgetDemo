//
//  ViewController.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 1/4/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    fileprivate var todayWidgetContent = TodayWidgetContent()

    @IBOutlet weak var todayContent: UITextView!
    
    @IBAction func displayContentTapped(_ sender: UIButton) {

        todayWidgetContent.text = todayContent.text
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        todayContent.text = todayWidgetContent.text
    }


}

