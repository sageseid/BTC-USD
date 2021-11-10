//
//  WebSocketResponseDecoder.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
//

import Foundation


struct WebSocketResponseDecoder {
    let channelId: Int
    let type: ResponseType
    
    enum ResponseType {
        case tickerSubscription
        case orderBookSubscription
        case ticker(Ticker)
        case orderBook(OrderBook)
        case orderBookItem(OrderBook.Item, type: OrderBook.ItemType)
    }
    
    
    init?(message: String) {
        let jsonDecoder = JSONDecoder()
        let jsonData = message.data(using: .utf8) ?? Data()
       
        if let numbersArray = try? jsonDecoder.decode([Double].self, from: jsonData) {
            switch numbersArray.count {
            case 11:
                // [ 2, 236.62, 9.0029, 236.88, 7.1138, -1.02, 0, 236.52, 5191.36754297, 250.01, 220.05 ]
                guard let (channelId, ticker) = WebSocketResponseDecoder.ticker(from: numbersArray) else {
                    return nil
                }
                self.channelId = channelId
                self.type = .ticker(ticker)
            case 4:
                // []
                guard let (channelId, item, type) = WebSocketResponseDecoder.orderBookItem(from: numbersArray) else {
                    return nil
                }
                self.channelId = channelId
                self.type = .orderBookItem(item, type: type)
            default:
                return nil
            }
        } else if let subscription = try? jsonDecoder.decode(OrderBookResponse.self, from: jsonData) {
            self.channelId = subscription.channelId
            self.type = .orderBookSubscription
        } else if let subscription = try? jsonDecoder.decode(TickerResponse.self, from: jsonData) {
            self.channelId = subscription.channelId
            self.type = .tickerSubscription
        } else if let (channelId, orderBook) = WebSocketResponseDecoder.orderBook(from: message) {
            self.channelId = channelId
            self.type = .orderBook(orderBook)
        } else {
            return nil
        }
    }
    
    
    static func ticker(from numbers: [Double]) -> (Int, Ticker)? {
// [ "<CHANNEL_ID>" , "<BID>", "<BID_SIZE>","<ASK>",  "<ASK_SIZE>", "<DAILY_CHANGE>", "<DAILY_CHANGE_PERC>","<LAST_PRICE>","<VOLUME>","<HIGH>","<LOW>"]
        
        guard numbers.count == 11 else {
            return nil
        }
        
        let channelId = Int(numbers[0])
        let bid = numbers[1]
        let ask = numbers[3]
        let ticker = Ticker(mid: (bid + ask) / 2, bid: bid, ask: ask, lastPrice: numbers[7], low: numbers[10], high: numbers[9], volume: numbers[8], dailyChange: numbers[5], dailyChangePerc: numbers[6])
        return (channelId, ticker)
    }
    
    static func orderBookItem(from numbers: [Double]) -> (Int, OrderBook.Item, OrderBook.ItemType)? {
//   ["<CHANNEL_ID>","<PRICE>","<COUNT>","<AMOUNT>"]
        guard numbers.count == 4 else {
            return nil
        }
        
        guard let (item, type) = internalOrderBookItem(from: Array(numbers[1...])) else {
            return nil
        }
        
        let channelId = Int(numbers[0])
        return (channelId, item, type)
    }
    
    private static func internalOrderBookItem(from numbers: [Double]) -> (OrderBook.Item, OrderBook.ItemType)? {
        
        guard numbers.count == 3 else {
            return nil
        }
        let item = OrderBook.Item(price: numbers[0], amount: abs(numbers[2]))
        let type: OrderBook.ItemType = (numbers[2] > 0) ? .bid : .ask
        return (item, type)
    }

    static func orderBook(from message: String) -> (Int, OrderBook)? {
        guard message.hasPrefix("[") && message.hasSuffix("]]]") else {
            return nil
        }
            
        let processedMessage = String(message.dropFirst().dropLast())
        guard let splitIndex = processedMessage.firstIndex(of: ",") else {
            return nil
        }
        
        guard let channelId = Int(processedMessage[..<splitIndex]) else {
            return nil
        }
        
        let arrayStartIndex = processedMessage.index(splitIndex, offsetBy: 1)
        let arrays = processedMessage[arrayStartIndex...]
        
        let arraysData = arrays.data(using: .utf8) ?? Data()
        guard let orderBookSnapshot = try? JSONDecoder().decode(OrderBookSnapshot.self, from: arraysData) else {
            return nil
        }
    
        var typedItems: [(OrderBook.Item, OrderBook.ItemType)] = orderBookSnapshot.items
            .map { internalOrderBookItem(from: $0) }
            .compactMap { $0 }
        
        let partitionIndex = typedItems.partition(by: { $0.1 == .ask })
        let bids = typedItems[..<partitionIndex].map { $0.0 }
        let asks = typedItems[partitionIndex...].map { $0.0 }
        return (channelId, OrderBook(bids: bids, asks: asks))
    }
}

