//
//  WSResponse.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/6/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
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
            print("numbersArray")
            print(numbersArray)
            switch numbersArray.count {
            case 11:
                // [ 2, 236.62, 9.0029, 236.88, 7.1138, -1.02, 0, 236.52, 5191.36754297, 250.01, 220.05 ]
                guard let (channelId, ticker) = WebSocketResponseDecoder.ticker(from: numbersArray) else {
                    return nil
                }
                print("ticker")
                self.channelId = channelId
                self.type = .ticker(ticker)
            case 4:
                // this should be an orderbook item
                guard let (channelId, item, type) = WebSocketResponseDecoder.orderBookItem(from: numbersArray) else {
                    return nil
                }
                print("order")
                self.channelId = channelId
                self.type = .orderBookItem(item, type: type)
            default:
                return nil
            }
        } else if let subscription = try? jsonDecoder.decode(OrderBookSubscription.self, from: jsonData) {
            print("order sub")
            self.channelId = subscription.channelId
            self.type = .orderBookSubscription
        } else if let subscription = try? jsonDecoder.decode(TickerSubscription.self, from: jsonData) {
            print("ticker sub")
            self.channelId = subscription.channelId
            self.type = .tickerSubscription
        } else if let (channelId, orderBook) = WebSocketResponseDecoder.orderBook(from: message) {
            print("order 2")
            self.channelId = channelId
            self.type = .orderBook(orderBook)
        } else {
            return nil
        }
    }
}




//
// Parsing details
//

// message factories
private extension WebSocketResponseDecoder {
    
    static func ticker(from numbers: [Double]) -> (Int, Ticker)? {
        
// [ "<CHANNEL_ID>" , "<BID>", "<BID_SIZE>","<ASK>",  "<ASK_SIZE>", "<DAILY_CHANGE>", "<DAILY_CHANGE_PERC>","<LAST_PRICE>","<VOLUME>","<HIGH>","<LOW>"]
        
        guard numbers.count == 11 else {
            return nil
        }

        let channelId = Int(numbers[0])
        let bid = numbers[1]
        let ask = numbers[3]
        let ticker = Ticker(mid: (bid + ask) / 2, bid: bid, ask: ask, lastPrice: numbers[7], low: numbers[10], high: numbers[9], volume: numbers[8], dailyChange: numbers[5], dailyChangePerc: numbers[6])  //, timestamp: nil,
        return (channelId, ticker)
    }
    
    static func orderBookItem(from numbers: [Double]) -> (Int, OrderBook.Item, OrderBook.ItemType)? {
//   ["<CHANNEL_ID>","<PRICE>","<COUNT>","<AMOUNT>"]
        // order book message should have also the channel id (the first element)
        
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
        
        // NOTE that the AMOUNT is positive for bids and negative for asks (but we'll keep it in OrderBook.Item only positive values, that's why we need the ItemType)
        let item = OrderBook.Item(price: numbers[0], amount: abs(numbers[2]))//, timestamp: nil)
        let type: OrderBook.ItemType = (numbers[2] > 0) ? .bid : .ask
        return (item, type)
    }

    static func orderBook(from message: String) -> (Int, OrderBook)? {
        
        // OrderBook snapshot messages have the following structure: [Int, [[Double]]]. Because of the first Int (the channelId), we cannot decode it easily, so it's simpler to extract that part, and leave only the [[Double]].
        guard message.hasPrefix("[") && message.hasSuffix("]]]") else {
            
            // not our guy!
            return nil
        }
            
        // OrderBook snapshot message recognized; we'll drop the surounding brackets
        let processedMessage = String(message.dropFirst().dropLast())
            
        // split the message in two parts: the Int and the [[Double]]
        guard let splitIndex = processedMessage.firstIndex(of: ",") else {
            return nil
        }
        
        guard let channelId = Int(processedMessage[..<splitIndex]) else {
            return nil
        }
        
        // advance to skip the "," character
        let arrayStartIndex = processedMessage.index(splitIndex, offsetBy: 1)
        let arrays = processedMessage[arrayStartIndex...]
        
        // now we should have an [[Double]]
        let arraysData = arrays.data(using: .utf8) ?? Data()
        guard let orderBookSnapshot = try? JSONDecoder().decode(OrderBookSnapshot.self, from: arraysData) else {
            print("BookOrder decoding failed!")
            return nil
        }
        
        // create the array of (item, itemType) array
        var typedItems: [(OrderBook.Item, OrderBook.ItemType)] = orderBookSnapshot.items
            .map { internalOrderBookItem(from: $0) }
            .compactMap { $0 }
        
        // partition them by type, discarding the type afterwards
        let partitionIndex = typedItems.partition(by: { $0.1 == .ask })
        let bids = typedItems[..<partitionIndex].map { $0.0 }
        let asks = typedItems[partitionIndex...].map { $0.0 }

        return (channelId, OrderBook(bids: bids, asks: asks))
    }
}
