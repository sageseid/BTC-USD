//
//  ReachabilityService.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/5/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
//

import Foundation
import RxSwift

class ReachabilityService: ReachabilityServiceType {
    
    var reachability: Observable<ReachabilityStatus> {
        return _reachabilitySubject?.asObservable() ?? Observable.never()
    }

    static let shared = try! ReachabilityService()
    
    // MARK: Private
    private let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>?
    private let _reachability: Reachability?
    
    private init() throws {
        
        var reachabilitySubject: BehaviorSubject<ReachabilityStatus>?
        
        let reachabilityRef = Reachability()
        if let reachabilityRef = reachabilityRef {
            
            reachabilitySubject = BehaviorSubject<ReachabilityStatus>(value: .unreachable)
            
            // so main thread isn't blocked when reachability via WiFi is checked
            let backgroundQueue = DispatchQueue(label: "reachability.wificheck", attributes: [])
            
            reachabilityRef.whenReachable = { reachability in
                print("Reachability is ON!")
                backgroundQueue.async {
                    reachabilitySubject?.on(.next(.reachable(viaWiFi: reachabilityRef.isReachableViaWiFi)))
                }
            }
            
            reachabilityRef.whenUnreachable = { reachability in
                print("Reachability is OFF!")
                backgroundQueue.async {
                    reachabilitySubject?.on(.next(.unreachable))
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
