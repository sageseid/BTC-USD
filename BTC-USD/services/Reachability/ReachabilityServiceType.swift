//
//  ReachabilityServiceType.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
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
