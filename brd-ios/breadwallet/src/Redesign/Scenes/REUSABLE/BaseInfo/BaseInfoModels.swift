//
//  BaseInfoModels.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 13.7.22.
//
//

import UIKit

protocol SimpleMessage: Equatable {
    var iconName: String { get }
    var title: String { get }
    var description: String { get }
    var firstButtonTitle: String? { get }
    var secondButtonTitle: String? { get }
}

enum BaseInfoModels {
    enum Section: Sectionable {
        case image
        case title
        case description
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    enum Assets {
        struct ViewAction {
            let type: PaymentCard.PaymentType
        }
        struct ActionResponse {
            var supportedCurrencies: [String]?
        }
        struct ResponseDisplay {
            var title: String?
            var currencies: [Currency]?
            var supportedCurrencies: [String]?
        }
    }
    
    enum SuccessReason: SimpleMessage {
        case buyCard
        case buyAch(OrderPreviewModels.AchDeliveryType?)
        case sell
        case documentVerification
        case limitsAuthentication
        
        var iconName: String {
            switch self {
            case .documentVerification:
                return Asset.ilVerificationsuccessfull.name
                
            default:
                return Asset.success.name
            }
        }
        
        var title: String {
            switch self {
            case .buyCard:
                return L10n.Buy.purchaseSuccessTitle
                
            case .buyAch:
                return L10n.Buy.bankAccountSuccessTitle
                
            case .sell:
                return L10n.Sell.withdrawalSuccessTitle
                
            case .documentVerification:
                return L10n.Account.idVerificationApproved
                
            case .limitsAuthentication:
                return L10n.Account.verificationSuccessful
            }
        }
        
        var description: String {
            switch self {
            case .buyCard:
                return L10n.Buy.purchaseSuccessText
                
            case .buyAch(let achDeliveryType):
                let text: String
                
                switch achDeliveryType {
                case .instant:
                    text = L10n.Buy.Ach.Instant.Success.description
                    
                default:
                    text = L10n.Buy.bankAccountSuccessText
                }
                
                return text
                
            case .sell:
                return L10n.Sell.withdrawalSuccessText
                
            case .documentVerification:
                return L10n.Account.startUsingWallet
                
            case .limitsAuthentication:
                return L10n.Account.VerificationSuccessful.description
            }
        }
        
        var firstButtonTitle: String? {
            switch self {
            case .documentVerification, .limitsAuthentication:
                return L10n.Button.buyDigitalAssets
                
            default:
                return L10n.Button.back
            }
        }
        
        var secondButtonTitle: String? {
            switch self {
            case .sell:
                return L10n.Sell.withdrawDetails
                
            case .documentVerification:
                return L10n.Button.receiveDigitalAssets
                
            case .limitsAuthentication:
                return L10n.Button.back
                
            default:
                return L10n.Buy.details
            }
        }
        
        var thirdButtonTitle: String? {
            switch self {
            case .documentVerification:
                return L10n.Button.fundWalletWithAch
                
            default:
                return nil
            }
        }
        
        var secondButtonUnderlined: Bool {
            switch self {
            case .documentVerification:
                return false
                
            default:
                return true
            }
        }
        
        var thirdButtoUnderlined: Bool {
            switch self {
            case .documentVerification:
                return false
                
            default:
                return true
            }
        }
        
        var secondButtonConfig: ButtonConfiguration {
            switch self {
            case .documentVerification:
                return Presets.Button.secondaryNoBorder
                
            default:
                return Presets.Button.noBorders
            }
        }
        
        var thirdButtonConfig: ButtonConfiguration {
            switch self {
            case .documentVerification:
                return Presets.Button.secondaryNoBorder
                
            default:
                return Presets.Button.noBorders
            }
        }
    }
    
    enum FailureReason: SimpleMessage {
        case buyCard(String?)
        case buyAch(OrderPreviewModels.AchDeliveryType?, String?)
        case swap
        case sell
        
        case plaidConnection
        case documentVerification
        case documentVerificationRetry
        case limitsAuthentication
        case livenessCheckLimit
        case veriffDeclined
        
        var iconName: String {
            switch self {
            case .documentVerification, .documentVerificationRetry:
                return Asset.ilVerificationunsuccessfull.name
                
            default:
                return Asset.error.name
            }
        }
        
        var title: String {
            switch self {
            case .buyCard, .buyAch, .livenessCheckLimit, .veriffDeclined, .sell:
                return L10n.Buy.errorProcessingPayment
                
            case .swap:
                return L10n.Swap.errorProcessingTransaction
                
            case .plaidConnection:
                return L10n.Buy.plaidErrorTitle
                
            case .documentVerification, .documentVerificationRetry:
                return L10n.Account.idVerificationRejected
                
            case .limitsAuthentication:
                return L10n.Account.verificationUnsuccessful
            }
        }
        
        var description: String {
            switch self {
            case .buyCard(let message):
                return message ?? L10n.Buy.failureTransactionMessage
                
            case .swap:
                return L10n.Swap.failureSwapMessage
                
            case .plaidConnection:
                return L10n.Buy.plaidErrorDescription
                
            case .buyAch(let achDeliveryType, let responseCode):
                let text: String
                
                switch achDeliveryType {
                case .instant, .normal:
                    switch responseCode {
                    case "30046":
                        text = L10n.ErrorMessages.Ach.accountClosed
                        
                    case "30R16":
                        text = L10n.ErrorMessages.Ach.accountFrozen
                        
                    case "20051":
                        text = L10n.ErrorMessages.Ach.insufficientFunds
                        
                    default:
                        text = L10n.ErrorMessages.Ach.errorWhileProcessing
                    }
                    
                default:
                    text = L10n.Buy.bankAccountFailureText
                }
                
                return text
                
            case .sell:
                return L10n.Sell.withdrawalErrorText
                
            case .documentVerification:
                return L10n.Account.IdVerificationRejected.description
                
            case .documentVerificationRetry:
                return L10n.Account.idVerificationRetry.replacingOccurrences(of: "-", with: "\u{2022}")
                
            case .limitsAuthentication:
                return L10n.Account.VerificationUnsuccessful.description.replacingOccurrences(of: "-", with: "\u{2022}")
                
            case .livenessCheckLimit:
                return L10n.ErrorMessages.LivenessCheckLimit.description
                
            case .veriffDeclined:
                return L10n.ErrorMessages.VeriffDeclined.description
            }
        }
        
        var firstButtonTitle: String? {
            switch self {
            case .swap:
                return L10n.Swap.retry
                
            case .documentVerification:
                return L10n.Account.contactUs
                
            case .livenessCheckLimit, .veriffDeclined:
                return L10n.ErrorMessages.tryAgainLater
                
            default:
                return L10n.PaymentConfirmation.tryAgain
            }
        }
        
        var secondButtonTitle: String? {
            switch self {
            case .swap:
                return L10n.Button.back
                
            case .documentVerification, .documentVerificationRetry, .limitsAuthentication:
                return L10n.Button.tryLater
                
            default:
                return L10n.UpdatePin.contactSupport
            }
        }
    }
    
    enum ComingSoonReason: SimpleMessage {
        case swap
        case buy
        case buyAch
        case sell
        case restrictedUSState
        case greyListedCountry
        
        var iconName: String { Asset.time.name }
        
        var title: String { L10n.Buy.Ach.notAvailableTitle }
        
        var description: String { L10n.ComingSoon.FeatureUnavailable.subtitle }
        
        var firstButtonTitle: String? { L10n.Swap.backToHome }
        
        var secondButtonTitle: String? { nil }
    }
}
