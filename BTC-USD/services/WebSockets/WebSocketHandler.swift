//
//  WSListener.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/6/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
//

import Foundation
import Starscream



class WebSocketHandler {
    
    private let socket = WebSocket(url: URL(string: WEBSOCKET_END_POINT)!)
    private let webSocketQueue = DispatchQueue(label: "odin-websocket")
    
    private var tickerSubscriptionChannelId: Int?
    private var orderBookSubscriptionChannelId: Int?
    private var currentOrderBook = OrderBook(bids: [], asks: [])
    
    var onTicker: ((Ticker) -> Void)?
    var onOrderBook: ((OrderBook) -> Void)?
    var onDisconnect: ((Error?) -> Void)?
    
    var isConnected: Bool {
        return socket.isConnected
    }
    
    
   


    init(){
        socket.callbackQueue = webSocketQueue
        socket.onConnect = { [weak self] in
            guard let self = self else { return }
            print("websocket is connected")
            self.resetSubscriptions()
            // start requests for both Ticker & OrderBook
            self.socket.write(string: WebSocketRequests.tickerRequest())
            self.socket.write(string: WebSocketRequests.orderBookRequest())//length: self.orderBookLength, frequency: self.updateFrequency))
        }
        
        socket.onDisconnect = { [weak self] (error: Error?) in
            print("websocket is disconnected: \(error?.localizedDescription ?? "")")
            
            self?.resetSubscriptions()
            self?.onDisconnect?(error)
        }
        
        socket.onText = { [weak self] (text: String) in
            guard let self = self else { return }
            
            guard let response = WSResponse(message: text) else {
                // unrecognized response!
                return
            }
            
            switch response.type {
            case .tickerSubscription:
                if self.tickerSubscriptionChannelId == nil {
                    
                    // subscribed!
                    print("Ticker subscribed: \(response.channelId)")
                    self.tickerSubscriptionChannelId = response.channelId
                }
                
            case .orderBookSubscription:
                if self.orderBookSubscriptionChannelId == nil {
                    
                    // subscribed!
                    print("OrderBook subscribed: \(response.channelId)")
                    self.orderBookSubscriptionChannelId = response.channelId
                }
                
            case .ticker(let ticker):
                if self.tickerSubscriptionChannelId == response.channelId {
                    self.onTicker?(ticker)
                }
                
            case .orderBook(let orderBook):
                if self.orderBookSubscriptionChannelId == response.channelId {
                    self.currentOrderBook = orderBook
                    self.onOrderBook?(orderBook)
                }
                
            case .orderBookItem(let item, let itemType):
                guard self.orderBookSubscriptionChannelId == response.channelId else {
                    return
                }

                let newBids = itemType == .bid ? [item] : []
                let newAsks = itemType == .ask ? [] : [item]
                
                // keep only the last N items for each category
                let bids = (newBids + self.currentOrderBook.bids).prefix(25)//self.orderBookLength)
                let asks = (newAsks + self.currentOrderBook.asks).prefix(25) //self.orderBookLength)
                self.currentOrderBook = OrderBook(bids: Array(bids), asks: Array(asks))
                self.onOrderBook?(self.currentOrderBook)
               
            }
        }
    }
    
    func connect() {
        if !socket.isConnected {
            socket.connect()
        }
    }
    
    private func resetSubscriptions() {
        tickerSubscriptionChannelId = nil
        orderBookSubscriptionChannelId = nil
    }
}
