//
//  SignInModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum SignInModels {
    typealias Item = (email: String?, password: String?)
    
    enum Section: Sectionable {
        case email
        case password
        case forgotPassword
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Validate {
        struct ViewAction {
            var email: String?
            var password: String?
        }
        
        struct ActionResponse {
            var isValid: Bool
        }
        
        struct ResponseDisplay {
            var isValid: Bool
        }
    }
}
