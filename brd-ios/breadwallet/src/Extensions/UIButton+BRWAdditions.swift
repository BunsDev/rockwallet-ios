//
//  UIButton+BRWAdditions.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-24.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit

extension UIButton {
    static func outline(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Fonts.button
        button.tintColor = LightColors.Text.one
        button.backgroundColor = LightColors.primary
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 0.5
        button.layer.borderColor = LightColors.Text.one.cgColor
        return button
    }
    
    static func buildModernCloseButton(position: NavBarButtonPosition) -> UIButton {
        let button = UIButton.icon(image: Asset.close.image,
                                   accessibilityLabel: L10n.AccessibilityLabels.close,
                                   position: position)
        button.tintColor = LightColors.Text.three
        return button
    }
    
    static func buildFaqButton(articleId: String, currency: Currency? = nil, position: NavBarButtonPosition, tapped: (() -> Void)? = nil) -> UIButton {
        let button = UIButton.icon(image: Asset.help.image, accessibilityLabel: L10n.AccessibilityLabels.faq, position: position)
        button.tintColor = LightColors.Text.three
        
        button.tap = {
            Store.trigger(name: .presentFaq(articleId, currency))
            tapped?()
        }
        
        return button
    }
    
    static func icon(image: UIImage?, accessibilityLabel: String, position: NavBarButtonPosition) -> UIButton {
        guard let image = image else { return UIButton() }
        
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.accessibilityLabel = accessibilityLabel
        button.tintColor = LightColors.Text.three
        
        return button
    }
    
    func tempDisable() {
        isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [weak self] in
            self?.isEnabled = true
        })
    }
}
