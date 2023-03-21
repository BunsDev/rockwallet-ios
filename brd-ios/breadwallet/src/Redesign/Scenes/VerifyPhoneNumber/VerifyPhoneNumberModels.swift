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
import PhoneNumberKit

enum VerifyPhoneNumberModels {
    typealias Item = Any?
    
    enum Section: Sectionable {
        case instructions
        case phoneNumber
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Validate {
        struct ViewAction {}
        
        struct ActionResponse {
            var isValid: Bool
        }
        
        struct ResponseDisplay {
            var isValid: Bool
        }
    }
    
    struct SetAreaCode {
        struct ViewAction {
            var areaCode: CountryCodePickerViewController.Country
        }
        struct ActionResponse {
            var areaCode: CountryCodePickerViewController.Country
            var phoneNumber: String?
        }
        struct ResponseDisplay {
            var areaCode: PhoneNumberViewModel
            var phoneNumber: String?
        }
    }
    
    struct SetPhoneNumber {
        struct ViewAction {
            var phoneNumber: String?
        }
    }
    
    struct Confirm {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
