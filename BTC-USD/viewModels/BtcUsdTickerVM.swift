//
//  TickerViewModel.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/4/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class BtcUsdTickerVM {
    let hasInternetConnection: Driver<Bool>
    let direction: Driver<Bool>
    let low: Driver<String?>
    let high: Driver<String?>
    let lastPrice: Driver<String?>
    let change: Driver<String?>
    let volume: Driver<String?>
  
    private let viewDidLoad = PublishSubject<Void>()
   
    init(){
        let ticker: Driver<Ticker> = viewDidLoad
            .flatMap { _ in  WSAPIService.shared.ticker()}
            .map { result in try? result.get() }
            .asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil }.map { $0! }
        
        self.hasInternetConnection = viewDidLoad
            .flatMapLatest { ReachabilityService.shared.reachability }
            .map { $0.reachable }
            .asDriver(onErrorJustReturn: true)
        
        self.lastPrice = ticker.map { ticker -> String? in
            guard let formattedValue = ValuesFormatter.priceFormat.string(from: NSNumber(value: ticker.lastPrice)) else { return nil }
            return "\(formattedValue)"
        }
        
        self.change = ticker.map { ticker -> String? in
            guard let dailyChangePerc = ticker.dailyChangePerc else { return nil }
            guard let formattedValue = ValuesFormatter.changesFormat.string(from: NSNumber(value: dailyChangePerc * 100)) else { return nil }
            return "\(formattedValue)%"
        }
        
        self.volume = ticker.map { ticker -> String? in
            ValuesFormatter.volumeFormat.string(from: NSNumber(value: ticker.volume))
        }
        
        self.low = ticker.map { ticker -> String? in
            guard let formattedValue = ValuesFormatter.priceFormat.string(from: NSNumber(value: ticker.low)) else { return nil }
            return "\(formattedValue)"
        }
        
        self.high = ticker.map { ticker -> String? in
            guard let formattedValue = ValuesFormatter.priceFormat.string(from: NSNumber(value: ticker.high)) else { return nil }
            return "\(formattedValue)"
        }
        
        self.direction = ticker.map { $0.direction }.unwrap()
    }
    
    func onViewDidLoad() {
        viewDidLoad.onNext(())
    }
}


extension SharedSequence where SharingStrategy == DriverSharingStrategy {
    func unwrap<T>() -> Driver<T> where Element == Optional<T> {
        return filter { $0 != nil }.map { $0! }
    }
}
