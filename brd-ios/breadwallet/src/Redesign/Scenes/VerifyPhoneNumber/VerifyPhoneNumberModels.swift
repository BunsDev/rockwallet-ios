//
//  SwapCurrencyView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum VerifyPhoneNumberModels {
    typealias Item = Any?
    
    enum Section: Sectionable {
        case instructions
        case phoneNumber
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Validate {
        struct ViewAction {
            var item: Item
        }
        
        struct ActionResponse {
            var isValid: Bool
        }
        
        struct ResponseDisplay {
            var isValid: Bool
        }
    }
    
    struct Confirm {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
    
    struct Resend {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
