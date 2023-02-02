//
//  BaseInfoModels.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 13.7.22.
//
//

import UIKit

enum BaseInfoModels {
    
    enum Section: Sectionable {
        case image
        case title
        case description
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    enum Assets {
        struct ViewAction { }
        struct ActionResponse {
            var supportedCurrencies: [SupportedCurrency]?
        }
        struct ResponseDisplay {
            var title: String?
            var currencies: [Currency]?
            var supportedCurrencies: [SupportedCurrency]?
        }
    }
}
