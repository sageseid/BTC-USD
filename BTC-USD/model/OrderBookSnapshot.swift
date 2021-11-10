//
//  OrderBookSnapshot.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 06/11/2021.
//

import Foundation
struct OrderBookSnapshot: Codable {
    let items: [[Double]]
    
    init(from decoder: Decoder) throws {
        var containersArray = try decoder.unkeyedContainer()
        
        var items = [[Double]]()
        
        var item: [Double]?
        repeat {
            item = try? containersArray.decode([Double].self)
            if let item = item {
                items.append(item)
            }
        } while item != nil
        
        self.items = items
    }
}
