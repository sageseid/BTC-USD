//
//  ReachabilityService.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
//

import Foundation
import RxSwift

class ReachabilityService{ 
    
    var reachability: Observable<Bool> {
        return _reachabilitySubject?.asObservable() ?? Observable.never()
    }

    static let shared = try! ReachabilityService()
    
    // MARK: Private
    private let _reachabilitySubject: BehaviorSubject<Bool>?
    private let _reachability: Reachability?
    
    private init() throws {
        
        var reachabilitySubject: BehaviorSubject<Bool>?
        
        let reachabilityRef = Reachability()
        if let reachabilityRef = reachabilityRef {
            
            reachabilitySubject = BehaviorSubject<Bool>(value: false)
            let backgroundQueue = DispatchQueue(label: "odin.network", attributes: [])
            reachabilityRef.whenReachable = { reachability in
                backgroundQueue.async {
                    reachabilitySubject?.on(.next(true))
                }
            }
            reachabilityRef.whenUnreachable = { reachability in
                backgroundQueue.async {
                    reachabilitySubject?.on(.next(false))
                }
            }
            try reachabilityRef.startNotifier()
        }
        _reachability = reachabilityRef
        _reachabilitySubject = reachabilitySubject
    }
    
    deinit {
        _reachability?.stopNotifier()
    }
}
