//
//  ExchangeDetailsModels.swift
//  breadwallet
//
//  Created by Rok on 06/07/2022.
//
//

import UIKit

enum ExchangeDetailsModels {
    typealias Item = (detail: ExchangeDetail, part: ExchangeDetail.SourceDestination.Part)
    
    enum Section: Sectionable {
        case header
        case order
        case buyOrder
        case fromCurrency
        case image
        case toCurrency
        case timestamp
        case transactionFrom
        case transactionTo
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct CopyValue {
        struct ViewAction {
            var value: String?
        }
        struct ActionResponse {}
    }
    
    struct InfoPopup {
        struct ViewAction {
            var isCardFee: Bool
        }
        struct ActionResponse {
            var isCardFee: Bool
        }
        struct ResponseDisplay {
            var model: PopupViewModel
        }
    }
}
