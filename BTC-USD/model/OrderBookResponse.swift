//
//  OrderBookResponse.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 06/11/2021.
//

import Foundation

struct OrderBookResponse: Codable {
    let event: String
    let channel: String
    let channelId: Int
    let precision: String
    let frequency: String
    let length: String
    let pair: String
    
    enum CodingKeys: String, CodingKey {
        case event
        case channel
        case channelId = "chanId"
        case precision = "prec"
        case frequency = "freq"
        case length = "len"
        case pair
    }
}
