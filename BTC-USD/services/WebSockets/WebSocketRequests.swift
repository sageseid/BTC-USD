//
//  WSRequest.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/6/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
//

import Foundation

struct WebSocketRequests {
        
    static func orderBook( ) -> String {
        let orderData = OrderRequest(event: "subscribe", channel: "book", pair: "BTCUSD", prec: "P0", freq: "F0", length: 50)
        let jsonEncoder = JSONEncoder()
        let orderJSONData = try! jsonEncoder.encode(orderData)
        return  String(data: orderJSONData, encoding: .utf8)!
        
    }
    
    static func ticker() -> String {
        let tickerData = TickerRequest(event: "subscribe", channel: "ticker", pair: "BTCUSD")
        let jsonEncoder = JSONEncoder()
        let tickerJSONData = try! jsonEncoder.encode(tickerData)
        return  String(data: tickerJSONData, encoding: .utf8)!
    }
}

