//
//  WebSocketHandler.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
//

import Foundation
import Starscream

class WebSocketHandler {
    private var tickerResponseChannelId: Int?
    private var orderBookResponseChannelId: Int?
    private var orderBook = OrderBook(bids: [], asks: [])
    
    var onTicker: ((Ticker) -> Void)?
    var onOrderBook: ((OrderBook) -> Void)?
    var onDisconnect: ((Error?) -> Void)?
 
    private let socket = WebSocket(url: URL(string: WEBSOCKET_END_POINT)!)
    private let webSocketQueue = DispatchQueue(label: "odin-websocket")
    
    func connect() {
        if !socket.isConnected {
            socket.connect()
        }
    }
    
    private func resetSubs() {
        tickerResponseChannelId = nil
        orderBookResponseChannelId = nil
    }
    
    init(){
        socket.callbackQueue = webSocketQueue
        socket.onConnect = { [weak self] in
            guard let self = self else { return }
            self.resetSubs()
            self.socket.write(string: WebSocketRequests.tickerRequest())
            self.socket.write(string: WebSocketRequests.orderBookRequest())
        }
        
        socket.onDisconnect = { [weak self] (error: Error?) in
            self?.resetSubs()
            self?.onDisconnect?(error)
        }
        
        socket.onText = { [weak self] (text: String) in
            guard let self = self else { return }
            guard let response = WebSocketResponseDecoder(message: text) else {
                return
            }
            
            switch response.type {
            case .tickerSubscription:
                if self.tickerResponseChannelId == nil {
                    self.tickerResponseChannelId = response.channelId
                }
                
            case .orderBookSubscription:
                if self.orderBookResponseChannelId == nil {
                    self.orderBookResponseChannelId = response.channelId
                }
                
            case .ticker(let ticker):
                if self.tickerResponseChannelId == response.channelId {
                    self.onTicker?(ticker)
                }
                
            case .orderBook(let orderBook):
                if self.orderBookResponseChannelId == response.channelId {
                    self.orderBook = orderBook
                    self.onOrderBook?(orderBook)
                }
                
            case .orderBookItem(let item, let itemType):
                guard self.orderBookResponseChannelId == response.channelId else {
                    return
                }
                let newBids = itemType == .bid ? [item] : []
                let newAsks = itemType == .ask ? [] : [item]
                let bids = (newBids + self.orderBook.bids).prefix(50)
                let asks = (newAsks + self.orderBook.asks).prefix(50)
                self.orderBook = OrderBook(bids: Array(bids), asks: Array(asks))
                self.onOrderBook?(self.orderBook)
            }
        }
    }
}
