//
//  SignUpModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum SignUpModels {
    typealias Item = (email: String?, password: String?, passwordAgain: String?)
    
    enum Section: Sectionable {
        case email
        case password
        case confirmPassword
        case notice
        case termsTickbox
        case promotionsTickbox
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Validate {
        struct ViewAction {
            var email: String?
            var password: String?
            var passwordAgain: String?
        }
        
        struct ActionResponse {
            var isEmailValid: Bool
            var isPasswordValid: Bool
            var isTermsTickboxValid: Bool
        }
        
        struct ResponseDisplay {
            var isEmailValid: Bool
            var isPasswordValid: Bool
            var isTermsTickboxValid: Bool
        }
    }
    
    struct TermsTickbox {
        struct ViewAction {
            var value: Bool
        }
    }
    
    struct PromotionsTickbox {
        struct ViewAction {
            var value: Bool
        }
    }
}
