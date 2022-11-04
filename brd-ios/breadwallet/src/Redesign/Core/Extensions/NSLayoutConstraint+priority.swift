// 
//  NSLayoutConstraint+priority.swift
//  breadwallet
//
//  Created by Rok on 11/05/2022.
//  Copyright © 2022 Placeholder, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension NSLayoutConstraint {
    func priority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
