//
//  Ticker.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/4/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
//

import Foundation

struct Ticker: Codable {
    let mid: Price
    let bid: Price
    let ask: Price
    let lastPrice: Price
    let low: Price
    let high: Price
    let volume: Price
    let timestamp: TimeInterval? // received ONLY on REST API
    let dailyChange: Price?      // received ONLY on websockets API
    let dailyChangePerc: Double? // received ONLY on websockets API

    enum CodingKeys: String, CodingKey {
        case mid
        case bid
        case ask
        case lastPrice = "last_price"
        case low
        case high
        case volume
        case timestamp
        case dailyChange
        case dailyChangePerc
    }
}

extension Ticker {
    
    var direction: PriceDirection? {
        guard let dailyChage = dailyChange else {
            return nil
        }
        return (dailyChage >= 0) ? .up : .down
    }
}

// custom decoding from REST API (strings are received)
extension Ticker {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let mid = Formatter.double(from: try container.decode(String.self, forKey: .mid)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .mid,
                in: container,
                debugDescription: "Cannot initialize mid from string"
            )
        }
        self.mid = mid
        
        guard let bid = Formatter.double(from: try container.decode(String.self, forKey: .bid)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .bid,
                in: container,
                debugDescription: "Cannot initialize bid from string"
            )
        }
        self.bid = bid

        guard let ask = Formatter.double(from: try container.decode(String.self, forKey: .ask)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .ask,
                in: container,
                debugDescription: "Cannot initialize ask from string"
            )
        }
        self.ask = ask

        guard let lastPrice = Formatter.double(from: try container.decode(String.self, forKey: .lastPrice)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .lastPrice,
                in: container,
                debugDescription: "Cannot initialize lastPrice from string"
            )
        }
        self.lastPrice = lastPrice

        guard let low = Formatter.double(from: try container.decode(String.self, forKey: .low)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .low,
                in: container,
                debugDescription: "Cannot initialize low from string"
            )
        }
        self.low = low
        
        guard let high = Formatter.double(from: try container.decode(String.self, forKey: .high)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .high,
                in: container,
                debugDescription: "Cannot initialize high from string"
            )
        }
        self.high = high

        guard let volume = Formatter.double(from: try container.decode(String.self, forKey: .volume)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .volume,
                in: container,
                debugDescription: "Cannot initialize volume from string"
            )
        }
        self.volume = volume
        
        let sTimestamp = try? container.decodeIfPresent(String.self, forKey: .timestamp)
        self.timestamp = (sTimestamp != nil) ? Formatter.double(from: sTimestamp!) : nil
        
        // will probably not decode, as it is not present in REST API response
        let sDailyChange = try? container.decodeIfPresent(String.self, forKey: .dailyChange)
        self.dailyChange = (sDailyChange != nil) ? Formatter.double(from: sDailyChange!) : nil

        // will probably not decode, as it is not present in REST API response
        let sDailyChangePerc = try? container.decodeIfPresent(String.self, forKey: .dailyChangePerc)
        self.dailyChangePerc = (sDailyChangePerc != nil) ? Formatter.double(from: sDailyChangePerc!) : nil
    }
}

