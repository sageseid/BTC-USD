//
//  WebSocketRequests.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
//

import Foundation

struct WebSocketRequests {
        
    static func orderBookRequest( ) -> String {
        let orderData = OrderRequest(event: "subscribe", channel: "book", pair: "BTCUSD", prec: "P0", freq: "F0", length: 50)
        let jsonEncoder = JSONEncoder()
        let orderJSONData = try! jsonEncoder.encode(orderData)
        return  String(data: orderJSONData, encoding: .utf8)!
    }
    
    static func tickerRequest() -> String {
        let tickerData = TickerRequest(event: "subscribe", channel: "ticker", pair: "BTCUSD")
        let jsonEncoder = JSONEncoder()
        let tickerJSONData = try! jsonEncoder.encode(tickerData)
        return  String(data: tickerJSONData, encoding: .utf8)!
    }
}

