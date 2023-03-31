//
//  RegistrationConfirmationModels.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

enum RegistrationConfirmationModels {
    typealias Item = (email: String?, phoneNumber: String?, confirmationType: RegistrationConfirmationModels.ConfirmationType)
    
    enum Section: Sectionable {
        case image
        case title
        case instructions
        case input
        case help
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    enum ConfirmationType {
        case account
        case twoStep
        case authenticationCode
    }
    
    struct Validate {
        struct ViewAction {
            var code: String?
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
    
    struct Error {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
