//
//  Storyboard.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/4/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
//

import UIKit

enum Storyboard: String {
    case main
    case orderBook
    case ticker
    
    var filename: String {
        return rawValue.capitalizingFirstLetter()
    }
}

extension Storyboard {
    
    func instantiate<T: UIViewController>(_ :T.Type) -> T {
        guard let instance = UIStoryboard(name: self.filename, bundle: Bundle.main)
                .instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else { fatalError("Couldn't instantiate \(T.storyboardIdentifier) from \(self.filename)")
        }
        
        return instance
    }
}
