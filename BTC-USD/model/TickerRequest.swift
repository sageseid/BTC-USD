//
//  TickerRequest.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 06/11/2021.
//

import Foundation

struct TickerRequest: Encodable {
    
    private(set)  public var  event: String!
    private(set)  public var  channel: String!
    private(set)  public var  pair: String!

    init (event: String, channel: String, pair: String){
        self.event = event
        self.channel = channel
        self.pair = pair
    }
}
