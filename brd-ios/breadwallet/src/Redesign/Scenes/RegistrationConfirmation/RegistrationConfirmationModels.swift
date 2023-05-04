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
        // Regular Login/Register without 2FA
        case account
        
        // Change 2FA method
        case twoStepAccountEmailSettings
        case twoStepAccountAppSettings
        
        // First time 2FA setup
        case twoStepEmail
        case twoStepApp
        
        // Login with 2FA
        case twoStepEmailLogin
        case twoStepAppLogin
        
        // Send funds with 2FA
        case twoStepEmailSendFunds
        case twoStepAppSendFunds
        
        // Buy with 2FA
        case twoStepEmailBuy
        case twoStepAppBuy
        
        // Reset password with 2FA
        case twoStepEmailResetPassword
        case twoStepAppResetPassword
        
        // 2FA app backup code
        case twoStepAppBackupCode
        
        // Disable 2FA
        case twoStepDisable
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
