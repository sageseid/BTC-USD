//
//  StoryboardInstantiable.swift
//  BTCTracker
//
//  Created by Florian Preknya on 9/4/19.
//  Copyright © 2019 Florian Preknya. All rights reserved.
//

import UIKit

extension UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
