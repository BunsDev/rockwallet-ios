// 
//  TouchSpamPreventer.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 14/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class TouchSpamPreventor {
    static var shared = TouchSpamPreventor()
    
    let views = [WrapperTableViewCell<FETextField>.self,
                 WrapperTableViewCell<NavigationItemView>.self,
                 WrapperTableViewCell<FESegmentControl>.self]
    
    func preventTouches(for view: UIView) {
        guard views.contains(where: { view.isKind(of: $0) }) else { return }
        
        guard view.isUserInteractionEnabled else { return }
        view.isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + Presets.Delay.long.rawValue) {
            view.isUserInteractionEnabled = true
        }
    }
}

extension UIView {
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        TouchSpamPreventor.shared.preventTouches(for: self)
    }
}
