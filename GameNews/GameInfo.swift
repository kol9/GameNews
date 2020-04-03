//
//  GameInfo.swift
//  GameNews
//
//  Created by Nikolay Yarlychenko on 02.04.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit


struct GamesInfo: Decodable {
    var appnews: GameInfo
}

struct GameInfo: Decodable {
    var appid: Int
    var newsitems: [NewsItem]
}

struct NewsItem: Decodable {
    var title: String
    var url: URL
    var contents: String
}
