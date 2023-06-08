// 
//  ExchangeFormatter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 12/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class ExchangeNumberFormatter: NumberFormatter {
    override func string(from: NSNumber) -> String {
        generatesDecimalNumbers = true
        numberStyle = .currency
        switch from {
        case _ where from.decimalValue < 1:
            usesSignificantDigits = true
            minimumSignificantDigits = 2
            maximumSignificantDigits = 4
            return super.string(from: from) ?? ""
            
        default:
            minimumFractionDigits = 2
            maximumFractionDigits = 2
            return super.string(from: from) ?? ""
        }
    }
    
    override func string(for obj: Any?) -> String? {
        guard let obj = obj as? NSNumber else { return nil }
        generatesDecimalNumbers = true
        switch obj {
        case _ where abs(obj.decimalValue) < 1:
            usesSignificantDigits = true
            minimumFractionDigits = 2
            minimumSignificantDigits = 2
            maximumSignificantDigits = 4
            return super.string(for: obj)
            
        default:
            minimumFractionDigits = 2
            maximumFractionDigits = 2
            return super.string(for: obj)
        }
    }
}

struct ExchangeFormatter {
    static var fiat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 14
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter
    }
    
    static var current: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 14
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 8
        
        return formatter
    }
    
    static func createAmountString(string: String) -> NSMutableAttributedString? {
        let attributedString = NSMutableAttributedString(string: string)
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingMiddle
        style.alignment = .right
        
        attributedString.addAttributes([
            .paragraphStyle: style,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: LightColors.Outline.two],
                                       range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
}

extension String {
    func sanitize(inputFormat: NumberFormatter, expectedFormat: NumberFormatter) -> String {
        // remove grouping separators
        var sanitized = replacingOccurrences(of: inputFormat.currencyGroupingSeparator, with: "")
        sanitized = sanitized.replacingOccurrences(of: inputFormat.groupingSeparator, with: "")

        // replace decimal separators
        sanitized = sanitized.replacingOccurrences(of: inputFormat.currencyDecimalSeparator, with: expectedFormat.decimalSeparator)
        sanitized = sanitized.replacingOccurrences(of: inputFormat.decimalSeparator, with: expectedFormat.decimalSeparator)
        
        return sanitized
    }
    
    func cleanupFormatting(forFiat: Bool) -> String {
        let text = isEmpty != false ? "0" : self
        
        let expectedFormat = forFiat ? ExchangeFormatter.fiat : ExchangeFormatter.current
        let inputFormat = ExchangeFormatter.current
        
        let sanitized = text.sanitize(inputFormat: inputFormat, expectedFormat: expectedFormat)
        
        return sanitized
    }
}
