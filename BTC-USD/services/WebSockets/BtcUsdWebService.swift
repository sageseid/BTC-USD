//
//  WSAPIService.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/5/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
//

import Foundation
import RxSwift


class BtcUsdWebService {
    static let shared = BtcUsdWebService()
    private var listener: WebSocketHandler
    private let reachabilityService: ReachabilityServiceType
    
    // THIS WAS GOTTEN FROM APISERVICETYPE
    typealias TickerResult = Result<Ticker, Error>
    typealias OrderBookResult = Result<OrderBook, Error>
    
    init(listener: WebSocketHandler = WebSocketHandler(),
         reachabilityService: ReachabilityServiceType = ReachabilityService.shared) {
        self.listener = listener
        self.reachabilityService = reachabilityService
    }
    
    func ticker() -> Observable<TickerResult> {
        return wsResults
            .filter { ticker, orderBook in ticker != nil }
            .map { ticker, orderBook in ticker! }
    }
    
    func orderBook() -> Observable<OrderBookResult> {
        return wsResults
            .filter { ticker, orderBook in orderBook != nil }
            .map { ticker, orderBook in orderBook! }
    }
    
    private lazy var wsResults: Observable<(TickerResult?, OrderBookResult?)> = {
        
        let reachabilityService = self.reachabilityService
        return Observable.deferred {
            return Observable<(TickerResult?, OrderBookResult?)>.create { [weak self] observer -> Disposable in
                
                print("Creating the WsResults observable...")
                self?.listener.onTicker = { data in
                    observer.onNext(
                        (TickerResult.success(data), nil)
                    )
                }
                self?.listener.onOrderBook = { data in
                    observer.onNext(
                        (nil, OrderBookResult.success(data))
                    )
                }
                
                self?.listener.onDisconnect = { error in
                    observer.onError(error ?? WSAPIServiceError.webSocketDisconnected)
                }
                
                self?.listener.connect()
                return Disposables.create()
            }
            }
            .retryWhen({ (errorObservable: Observable<Error>) -> Observable<Void> in
                errorObservable.flatMap { [weak self] _ -> Observable<()> in
                    print("WSListener error, retrying to establish connection if/when network is on...")
                    return reachabilityService.reachability
                        .filter { $0.reachable }
                        .map { _ in () }
                }
            })
//            .debug("WSAPIService")
            .share(replay: 1)
    }()
}

// just an internal error, not sent to clients
private enum WSAPIServiceError: Error {
    case webSocketDisconnected
}
