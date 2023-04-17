//
//  ProfileModels.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

enum ProfileModels {
    typealias Item = ()
    
    enum Section: Sectionable {
        case profile
        case verification
        case navigation
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    enum NavigationItems: String, CaseIterable {
        case paymentMethods
        case security
        case preferences
        case logout
    }
    
    enum ExchangeFlow {
        case buy
        case swap
        case sell
    }
    
    struct Navigate {
        struct ViewAction {
            var index: Int
        }
        struct ActionResponse {
            var index: Int
        }
        struct ResponseDisplay {
            var item: NavigationItems
        }
    }
    
    struct VerificationInfo {
        struct ViewAction {}
        struct ActionResponse {
            var verified: Bool
        }
        struct ResponseDisplay {
            var model: PopupViewModel
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
    
    struct Logout {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}

extension ProfileModels.NavigationItems {
    var model: NavigationViewModel {
        switch self {
        case .paymentMethods:
            return .init(image: .image(Asset.card.image),
                         label: .text(L10n.Buy.paymentMethod),
                         button: .init(image: nil))
            
        case .security:
            return .init(image: .image(Asset.lockClosed.image),
                         label: .text(L10n.MenuButton.security),
                         button: .init(image: nil))

        case .preferences:
            return .init(image: .image(Asset.settings.image),
                         label: .text(L10n.Settings.preferences),
                         button: .init(image: nil))
        case .logout:
            return .init(image: .image(Asset.logout.image),
                         label: .text(L10n.Account.logout),
                         button: .init(image: nil))
        }
    }
}
