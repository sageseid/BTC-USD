//
//  BtcUsdOrderBookVM.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
//

import Foundation
import RxSwift
import RxCocoa

class BtcUsdOrderBookVM {
    
    let orderBookData = PublishSubject<Void>()
    private let isLoadingRelay = BehaviorRelay(value: false)
    
    let sells: Driver<[OrderBook.Item]>
    let buys: Driver<[OrderBook.Item]>
    
    var isLoading: Driver<Bool> {
        let isLoadingRelay = self.isLoadingRelay
        return orderBookData.flatMapLatest {
            isLoadingRelay
        }.asDriver(onErrorJustReturn: false)
    }
    
    func onNext() {
        orderBookData.onNext(())
    }
    
    init(){
        let isLoadingRelay = self.isLoadingRelay
        let emptyOrderBook = OrderBook(bids: [], asks: [])
        let orderBook: Driver<OrderBook> = orderBookData
            .do(onNext: { _ in
                isLoadingRelay.accept(true)
            })
            .flatMapLatest { () -> Observable<OrderBook> in
                return  BtcUsdWebService.shared.orderBook()
                    .do(onNext: { _ in
                        isLoadingRelay.accept(false)
                    })
                    .map { result in try? result.get() }
                    .unwrap()
            }
            .asDriver(onErrorJustReturn: emptyOrderBook)
        self.sells = orderBook.map { $0.asks }
        self.buys = orderBook.map { $0.bids }
    }
}

extension Observable {
    /// Returns an `Observable` where the nil values from the original `Observable` are skipped
       func unwrap<T>() -> Observable<T> where Element == T? {
           self.filter { $0 != nil }.map { $0! }
       }
}

