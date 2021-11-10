//
//  TickerSubscription.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 06/11/2021.
//

import Foundation

struct TickerResponse: Codable {
    let event: String
    let channel: String
    let channelId: Int
    let pair: String
    
    enum CodingKeys: String, CodingKey {
        case event
        case channel
        case channelId = "chanId"
        case pair
    }
}
