//
//  BtcUsdOrderBookViewModel.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
//

import Foundation
import RxSwift
import RxCocoa

class BtcUsdOrderBookVM {
    
    let viewDidLoad = PublishSubject<Void>()
    private let isLoadingRelay = BehaviorRelay(value: false)
    
    let sells: Driver<[OrderBook.Item]>
    let buys: Driver<[OrderBook.Item]>
    
    var isLoading: Driver<Bool> {
        let isLoadingRelay = self.isLoadingRelay
        return viewDidLoad.flatMapLatest {
            isLoadingRelay
        }.asDriver(onErrorJustReturn: false)
    }
    
    init(){
        let isLoadingRelay = self.isLoadingRelay
        let emptyOrderBook = OrderBook(bids: [], asks: [])
        let orderBook: Driver<OrderBook> = viewDidLoad
            .do(onNext: { _ in
                isLoadingRelay.accept(true)
            })
            .flatMapLatest { () -> Observable<OrderBook> in
                return  WSAPIService.shared.orderBook() //service.orderBook()
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
    
    func onViewDidLoad() {
        viewDidLoad.onNext(())
    }
}

extension Observable {
    /// Returns an `Observable` where the nil values from the original `Observable` are skipped
       func unwrap<T>() -> Observable<T> where Element == T? {
           self.filter { $0 != nil }.map { $0! }
       }
}

