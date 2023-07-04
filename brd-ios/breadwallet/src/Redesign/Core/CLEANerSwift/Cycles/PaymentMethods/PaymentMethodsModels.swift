// 
//  PaymentMethodsModels.swift
//  breadwallet
//
//  Created by Rok on 12/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import LinkKit

enum PaymentMethodsModels {
    enum Get {
        struct ViewAction {
            var openCards: Bool?
        }
        
        struct ActionResponse {
            var item: PaymentCard?
        }
        
        struct ResponseDisplay {
            var viewModel: CardSelectionViewModel?
        }
    }
    
    struct SetPaymentCard {
        struct ViewAction {
            var card: PaymentCard?
        }
    }
    
    struct PaymentCards {
        struct ViewAction {}
        
        struct ActionResponse {
            var allPaymentCards: [PaymentCard]
        }
        
        struct ResponseDisplay {
            var allPaymentCards: [PaymentCard]
        }
    }
    
    enum Link {
        struct ViewAction {}
        
        struct ActionResponse {
            var plaidHandler: PlaidLinkKitHandler
        }
        
        struct ResponseDisplay {
            var plaidHandler: PlaidLinkKitHandler
        }
    }
}