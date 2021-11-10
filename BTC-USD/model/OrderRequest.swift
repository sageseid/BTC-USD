//
//  OrderRequest.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 06/11/2021.
//

import Foundation
struct OrderRequest: Encodable {
    
    private(set)  public var  event: String!
    private(set)  public var  channel: String!
    private(set)  public var  pair: String!
    private(set)  public var  prec: String!
    private(set)  public var  freq: String!
    private(set)  public var  length: Int!
    
    init (event: String, channel: String, pair: String, prec: String, freq: String, length: Int){
        self.event = event
        self.channel = channel
        self.pair = pair
        self.prec = prec
        self.freq = freq
        self.length = length
    }
}
