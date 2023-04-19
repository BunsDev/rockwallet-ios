//
//  PaymailAddressModels.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.4.23.
//
//

import UIKit

enum PaymailAddressModels {
    typealias Item = (PaymailAddressModels.ScreenType?)
    
    enum Section: Sectionable {
        case description
        case emailView
        case paymail
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    enum ScreenType {
        case paymailSetup
        case paymailNotSetup
        
        var description: String {
            switch self {
            case .paymailNotSetup:
                return "To enable quick BSV transfers you can create your unique Paymail address. "
            case .paymailSetup:
                return L10n.PaymailAddress.description
            }
        }
        
        var image: UIImage {
            switch self {
            case .paymailSetup:
                return Asset.copyIcon.image
            case .paymailNotSetup:
                return Asset.cancel.image
            }
        }
        
        var emailViewTitle: String {
            switch self {
            case .paymailSetup:
                return "Paymail address"
            case .paymailNotSetup:
                return L10n.PaymailAddress.yourPaymailAddress
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .paymailSetup:
                return L10n.Button.back
            case .paymailNotSetup:
                return "Create paymail address"
            }
        }
    }
    
    struct InfoPopup {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {
            var model: PopupViewModel
        }
    }
    
    struct Success {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
