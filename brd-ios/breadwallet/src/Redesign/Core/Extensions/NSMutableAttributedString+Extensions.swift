// 
//  NSMutableAttributedString+Extensions.swift
//  breadwallet
//
//  Created by Dino Gacevic on 19/06/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    func preparePaymentMethodUnavailableText() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: L10n.PaymentMethod.unavailable)
        
        let maxRange = NSRange(location: 0, length: attributedString.mutableString.length)
        attributedString.addAttribute(.font, value: Fonts.Body.three, range: maxRange)
        attributedString.addAttribute(.foregroundColor, value: LightColors.Error.one, range: maxRange)
        
        let range = attributedString.mutableString.range(of: L10n.Buy.PaymentMethodBlocked.link)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        attributedString.addAttribute(.font, value: Fonts.Subtitle.three, range: range)
        
        return attributedString
    }
}
