//
//  OrderBook.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 06/11/2021.
//

import Foundation

struct OrderBook: Codable {
    struct Item: Codable, Equatable {
        let price: Double
        let amount: Double
    }
    
    let bids: [Item]
    let asks: [Item]
    
    
    enum ItemType {
        case bid
        case ask
    }
}


extension OrderBook.Item {
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let price = ValuesFormatter.double(from: try container.decode(String.self, forKey: .price)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .price,
                in: container,
                debugDescription: "Cannot initialize price from string"
            )
        }
        self.price = price
        
        guard let amount = ValuesFormatter.double(from: try container.decode(String.self, forKey: .amount)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .amount,
                in: container,
                debugDescription: "Cannot initialize amount from string"
            )
        }
        self.amount = amount
    }
}
