//
//  OrderBook.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/4/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
//

import Foundation

struct OrderBook: Codable {
    
    struct Item: Codable, Equatable {
        let price: Price
        let amount: Double
        let timestamp: TimeInterval? // received ONLY on REST API
    }
    
    let bids: [Item]
    let asks: [Item]
}

// custom decoding from REST API (strings are received)
extension OrderBook.Item {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let price = Formatter.double(from: try container.decode(String.self, forKey: .price)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .price,
                in: container,
                debugDescription: "Cannot initialize price from string"
            )
        }
        self.price = price
        
        guard let amount = Formatter.double(from: try container.decode(String.self, forKey: .amount)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .amount,
                in: container,
                debugDescription: "Cannot initialize amount from string"
            )
        }
        self.amount = amount
        
        let sTimestamp = try? container.decodeIfPresent(String.self, forKey: .timestamp)
        self.timestamp = (sTimestamp != nil) ? Formatter.double(from: sTimestamp!) : nil
    }
}
