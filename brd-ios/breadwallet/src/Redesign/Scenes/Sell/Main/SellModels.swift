//
//  SellModels.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

enum SellModels {
    struct Item: Hashable {
        var type: PaymentCard.PaymentType?
        var achEnabled: Bool?
    }
    
    struct Assets {
        struct ViewAction {
            var currency: String?
            var card: PaymentCard?
        }
        
        struct ActionResponse {
            var amount: Amount?
            var card: PaymentCard?
            var type: PaymentCard.PaymentType?
            var quote: Quote?
            var handleErrors = false
        }
        
        struct ResponseDisplay {
            var cryptoModel: MainSwapViewModel?
            var cardModel: MainSwapViewModel?
        }
    }
    
    struct Fee {
        struct ViewAction {}
        
        struct ActionResponse {
            var to: Decimal?
        }
        
        struct ResponseDisplay {
            var to: String?
        }
    }
    
    struct PaymentCards {
        struct ViewAction {
            var getCards: Bool?
        }
        
        struct ActionResponse {
            var allPaymentCards: [PaymentCard]
        }
        
        struct ResponseDisplay {
            var allPaymentCards: [PaymentCard]
        }
    }
    
    struct Amounts {
        struct ViewAction {
            var fiatValue: String?
            var tokenValue: String?
        }
    }
    
    struct Limits {
        struct ActionResponse {
            var min: Decimal?
            var max: Decimal?
        }
        
        typealias ResponseDisplay = LabelViewModel
    }
    
    struct OrderPreview {
        struct ViewAction {}
        
        struct ActionResponse {
            var availablePayments: [PaymentCard.PaymentType]?
        }
        
        struct ResponseDisplay {
            var availablePayments: [PaymentCard.PaymentType]?
        }
    }
    
    struct AssetSelector {
        struct ViewAction {}
        
        struct ActionResponse {}
        
        struct ResponseDisplay {
            let title: String
        }
    }
    
    struct PaymentMethod {
        struct ViewAction {
            let method: PaymentCard.PaymentType
        }
        
        struct ActionResponse {}
        
        struct ResponseDisplay {}
    }
    
    struct AchData {
        struct ViewAction {}
        
        struct ActionResponse {
            var currencyCode: String?
        }
        
        struct ResponseDisplay {
            var model: InfoViewModel?
            var config: InfoViewConfiguration?
        }
    }
    
    struct RetryPaymentMethod {
        struct ViewAction {
            let method: PaymentCard.PaymentType
        }
        
        struct ActionResponse {
            let method: PaymentCard.PaymentType
        }
        
        struct ResponseDisplay {}
    }
    
    struct AchSuccess {
        struct ViewAction {}
        
        struct ActionResponse {
            var isRelinking: Bool?
        }
        
        struct ResponseDisplay {}
    }
    
    struct LimitsInfo {
        struct ViewAction {}
        struct ActionResponse {
            var paymentMethod: PaymentCard.PaymentType?
        }
        struct ResponseDisplay {
            var config: WrapperPopupConfiguration<LimitsPopupConfiguration>
            var viewModel: WrapperPopupViewModel<LimitsPopupViewModel>
        }
    }
    
    struct InstantAchPopup {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {
            var model: PopupViewModel
        }
    }
    
    struct AssetSelectionMessage {
        struct ViewAction {}
        
        struct ActionResponse {}
        
        struct ResponseDisplay {
            var model: InfoViewModel?
            var config: InfoViewConfiguration?
        }
    }
}
