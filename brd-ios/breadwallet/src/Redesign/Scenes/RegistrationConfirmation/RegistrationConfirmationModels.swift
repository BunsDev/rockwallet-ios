//
//  RegistrationConfirmationModels.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

enum RegistrationConfirmationModels {
    typealias Item = (type: RegistrationConfirmationModels.ConfirmationType, email: String?)
    
    enum Section: Sectionable {
        case image
        case title
        case instructions
        case input
        case help
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    enum ConfirmationType: Hashable {
        // Regular Login/Register
        case account
        
        // Change method
        case acountTwoStepEmailSettings
        case acountTwoStepAppSettings
        
        // First time setup
        case twoStepEmail
        case twoStepApp
        
        // Login
        case twoStepEmailLogin
        case twoStepAppLogin
        
        // Reset password
        case twoStepEmailResetPassword
        case twoStepAppResetPassword
        
        // App backup code
        case enterAppBackupCode
        
        // Disable 2FA
        case disable
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
    
    struct NextFailure {
        struct ActionResponse {
            let reason: NetworkingError
            var registrationRequestData: RegistrationRequestData?
            var setPasswordRequestData: SetPasswordRequestData?
        }
        struct ResponseDisplay {
            let reason: NetworkingError
            var registrationRequestData: RegistrationRequestData?
            var setPasswordRequestData: SetPasswordRequestData?
        }
    }
}
