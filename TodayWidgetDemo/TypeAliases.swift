//
//  TypeAliases.swift
//  TodayWidgetDemo
//
//  Created by Bob Wakefield on 2/15/20.
//  Copyright © 2020 Cockleburr Software. All rights reserved.
//

import UIKit

typealias ImageResult = Result<UIImage, Error>

typealias FileDownloadResult = Result<URL, Error>


typealias PokemonCompletion = (Result<(Pokemon, UIImage), Error>) -> Void
