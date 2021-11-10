//
//  BtcUsdWebService.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
//

import Foundation
import RxSwift


class BtcUsdWebService {
    static let shared = BtcUsdWebService()
    private var handler: WebSocketHandler
    private let reachabilityService: ReachabilityServiceType
    
    typealias TickerResult = Result<Ticker, Error>
    typealias OrderBookResult = Result<OrderBook, Error>
    
    init(listener: WebSocketHandler = WebSocketHandler(),
         reachabilityService: ReachabilityServiceType = ReachabilityService.shared) {
        self.handler = listener
        self.reachabilityService = reachabilityService
    }
    
    func ticker() -> Observable<TickerResult> {
        return webSocketResponse
            .filter { ticker, orderBook in ticker != nil }
            .map { ticker, orderBook in ticker! }
    }
    
    func orderBook() -> Observable<OrderBookResult> {
        return webSocketResponse
            .filter { ticker, orderBook in orderBook != nil }
            .map { ticker, orderBook in orderBook! }
    }
    
    private lazy var webSocketResponse: Observable<(TickerResult?, OrderBookResult?)> = {
        let reachabilityService = self.reachabilityService
        return Observable.deferred {
            return Observable<(TickerResult?, OrderBookResult?)>.create { [weak self] observer -> Disposable in
                
                self?.handler.onTicker = { data in
                    observer.onNext(
                        (TickerResult.success(data), nil)
                    )
                }
                
                self?.handler.onOrderBook = { data in
                    observer.onNext(
                        (nil, OrderBookResult.success(data))
                    )
                }
                
                self?.handler.onDisconnect = { error in
                    observer.onError(NSError(domain: "My domain", code: -1, userInfo: nil))
                }
                self?.handler.connect()
                return Disposables.create()
              }
            }
            .retryWhen({ (errorObservable: Observable<Error>) -> Observable<Void> in
                errorObservable.flatMap { [weak self] _ -> Observable<()> in
                    return reachabilityService.reachability
                        .filter { $0.reachable }
                        .map { _ in () }
                }
            })
            .share(replay: 1)
    }()
}

