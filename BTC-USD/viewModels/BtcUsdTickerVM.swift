//
//  BtcUsdTickerVM.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
//

import Foundation
import RxSwift
import RxCocoa

class BtcUsdTickerVM {
    private let tickerData = PublishSubject<Void>()
    
    func onNext() {
        tickerData.onNext(())
    }
    
    let hasInternetConnection: Driver<Bool>
    let direction: Driver<Bool>
    let low: Driver<String?>
    let high: Driver<String?>
    let lastPrice: Driver<String?>
    let change: Driver<String?>
    let volume: Driver<String?>
    
    init(){
        let ticker: Driver<Ticker> = tickerData
            .flatMap { _ in  BtcUsdWebService.shared.ticker()}
            .map { result in try? result.get() }
            .asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil }.map { $0! }
        
        self.hasInternetConnection = tickerData
            .flatMapLatest { ReachabilityService.shared.reachability }
            .map { $0 }
            .asDriver(onErrorJustReturn: true)
        
        self.low = ticker.map { ticker -> String? in
            guard let formattedlow = ValuesFormatter.priceFormat.string(from: NSNumber(value: ticker.low)) else { return nil }
            return "\(formattedlow)"
        }
        
        self.high = ticker.map { ticker -> String? in
            guard let formattedhigh = ValuesFormatter.priceFormat.string(from: NSNumber(value: ticker.high)) else { return nil }
            return "\(formattedhigh)"
        }
        
        self.lastPrice = ticker.map { ticker -> String? in
            guard let formattedlastPrice = ValuesFormatter.priceFormat.string(from: NSNumber(value: ticker.lastPrice)) else { return nil }
            return "\(formattedlastPrice)"
        }
        
        self.change = ticker.map { ticker -> String? in
        guard let formattedChangePerc = ValuesFormatter.changesFormat.string(from: NSNumber(value: ticker.dailyChangePerc! * 100)) else { return nil }
            return "\(formattedChangePerc)%"
        }
        
        self.volume = ticker.map { ticker -> String? in
            ValuesFormatter.volumeFormat.string(from: NSNumber(value: ticker.volume))
        }
        
        self.direction = ticker.map { $0.direction }.unwrap()
    }
}


extension SharedSequence where SharingStrategy == DriverSharingStrategy {
    func unwrap<T>() -> Driver<T> where Element == Optional<T> {
        return filter { $0 != nil }.map { $0! }
    }
}
