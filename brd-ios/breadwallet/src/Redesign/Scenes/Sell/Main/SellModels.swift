//
//  SellModels.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit
import WalletKit

enum SellModels {
    struct Item: Hashable {
        var type: PaymentCard.PaymentType?
        var achEnabled: Bool?
    }
    
    struct Fee {
        struct ViewAction {}
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
