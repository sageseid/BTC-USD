//
//  Ticker.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 06/11/2021.
//

import Foundation

struct Ticker: Codable {
    let mid: Double
    let bid: Double
    let ask: Double
    let lastPrice: Double
    let low: Double
    let high: Double
    let volume: Double
    let dailyChange: Double?
    let dailyChangePerc: Double?
    
    var direction: Bool? {
        guard let dailyChange = dailyChange else {
            return nil
        }
        if (dailyChange >= 0){
            return true
        } else {
            return false
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case mid
        case bid
        case ask
        case lastPrice = "last_price"
        case low
        case high
        case volume
        case dailyChange
        case dailyChangePerc
    }
}

extension Ticker {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let mid = ValuesFormatter.double(from: try container.decode(String.self, forKey: .mid)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .mid,
                in: container,
                debugDescription: "Cannot initialize mid from string"
            )
        }
        self.mid = mid
        
        guard let bid = ValuesFormatter.double(from: try container.decode(String.self, forKey: .bid)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .bid,
                in: container,
                debugDescription: "Cannot initialize bid from string"
            )
        }
        self.bid = bid

        guard let ask = ValuesFormatter.double(from: try container.decode(String.self, forKey: .ask)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .ask,
                in: container,
                debugDescription: "Cannot initialize ask from string"
            )
        }
        self.ask = ask

        guard let lastPrice = ValuesFormatter.double(from: try container.decode(String.self, forKey: .lastPrice)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .lastPrice,
                in: container,
                debugDescription: "Cannot initialize lastPrice from string"
            )
        }
        self.lastPrice = lastPrice

        guard let low = ValuesFormatter.double(from: try container.decode(String.self, forKey: .low)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .low,
                in: container,
                debugDescription: "Cannot initialize low from string"
            )
        }
        self.low = low
        
        guard let high = ValuesFormatter.double(from: try container.decode(String.self, forKey: .high)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .high,
                in: container,
                debugDescription: "Cannot initialize high from string"
            )
        }
        self.high = high

        guard let volume = ValuesFormatter.double(from: try container.decode(String.self, forKey: .volume)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .volume,
                in: container,
                debugDescription: "Cannot initialize volume from string"
            )
        }
        self.volume = volume
        
        let sDailyChange = try? container.decodeIfPresent(String.self, forKey: .dailyChange)
        self.dailyChange = (sDailyChange != nil) ? ValuesFormatter.double(from: sDailyChange!) : nil

        let sDailyChangePerc = try? container.decodeIfPresent(String.self, forKey: .dailyChangePerc)
        self.dailyChangePerc = (sDailyChangePerc != nil) ? ValuesFormatter.double(from: sDailyChangePerc!) : nil
    }
}
