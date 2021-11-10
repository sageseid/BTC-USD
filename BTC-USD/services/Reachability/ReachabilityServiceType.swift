//
//  ReachabilityServiceType.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/5/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
//

import Foundation
import RxSwift

public enum ReachabilityStatus {
    case reachable(viaWiFi: Bool)
    case unreachable
}

public extension ReachabilityStatus {
    var reachable: Bool {
        switch self {
        case .reachable:
            return true
        case .unreachable:
            return false
        }
    }
}

protocol ReachabilityServiceType {
    var reachability: Observable<ReachabilityStatus> { get }
}
