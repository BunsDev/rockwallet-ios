// 
//  FailureViewController.swift
//  breadwallet
//
//  Created by Rok on 12/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

// Currently not used, but if we need to, we can expand the VC with this protocol instead of enum directly
protocol SimpleMessage {
    var iconName: String { get }
    var title: String { get }
    var description: String { get }
    var firstButtonTitle: String? { get }
    var secondButtonTitle: String? { get }
}

enum FailureReason: SimpleMessage {
    case buyCard
    case buyAch
    case swap
    case plaidConnection
    case sell
    case documentVerification
    case documentVerificationRetry
    
    var iconName: String {
        switch self {
        case .documentVerification:
            return Asset.ilVerificationunsuccessfull.name
            
        default:
            return Asset.error.name
        }
    }
    
    var title: String {
        switch self {
        case .buyCard, .buyAch:
            return L10n.Buy.errorProcessingPayment
            
        case .swap, .sell:
            return L10n.Swap.errorProcessingTransaction
            
        case .plaidConnection:
            return L10n.Buy.plaidErrorTitle
            
        case .documentVerification, .documentVerificationRetry:
            return L10n.Account.idVerificationRejected
        }
    }
    
    var description: String {
        switch self {
        case .buyCard:
            return L10n.Buy.failureTransactionMessage
            
        case .swap:
            return L10n.Swap.failureSwapMessage
            
        case .plaidConnection:
            return L10n.Buy.plaidErrorDescription
            
        case .buyAch:
            return L10n.Buy.bankAccountFailureText
            
        case .sell:
            return L10n.Sell.tryAgain
            
        case .documentVerification:
            return L10n.Account.IdVerificationRejected.description
            
        case .documentVerificationRetry:
            return "description 2"
        }
    }
    
    var firstButtonTitle: String? {
        switch self {
        case .swap:
            return L10n.Swap.retry
            
        case .documentVerification:
            return "Contact us"
            
        default:
            return L10n.PaymentConfirmation.tryAgain
        }
    }
    
    var secondButtonTitle: String? {
        switch self {
        case .swap:
            return L10n.Swap.backToHome
            
        case .documentVerification, .documentVerificationRetry:
            return L10n.Button.tryLater
            
        default:
            return L10n.UpdatePin.contactSupport
        }
    }
}

extension Scenes {
    static let Failure = FailureViewController.self
}

class FailureViewController: BaseInfoViewController {
    var buttonTitle: String?
    var availablePayments: [PaymentCard.PaymentType]?
    var failure: FailureReason? {
        didSet {
            prepareData()
        }
    }
    override var imageName: String? { return failure?.iconName }
    override var titleText: String? { return failure?.title }
    override var descriptionText: String? { return failure?.description }
    override var buttonViewModels: [ButtonViewModel] {
        let containsDebit = availablePayments?.contains(.card) == true
        let containsBankAccount = availablePayments?.contains(.ach) == true
        if containsDebit || containsBankAccount {
            buttonTitle = containsDebit ? L10n.PaymentConfirmation.tryWithDebit : L10n.PaymentConfirmation.tryWithAch
        }
        return [
            .init(title: buttonTitle != nil ? buttonTitle : failure?.firstButtonTitle) { [weak self] in
                switch self?.failure {
                case .swap:
                    self?.coordinator?.showSwap()
                    
                case .documentVerification:
                    // show custumer support
                    break
                    
                case .documentVerificationRetry:
                    // retry document verification
                    break
                    
                default:
                    if containsDebit || containsBankAccount {
                        self?.coordinator?.showBuyWithDifferentPayment(paymentMethod: containsDebit ? .card : .ach)
                    } else {
                        self?.coordinator?.showBuy()
                    }
                }},
            .init(title: failure?.secondButtonTitle, isUnderlined: true, callback: { [weak self] in
                switch self?.failure {
                case .buyCard:
                    self?.coordinator?.showSupport()
                    
                case .swap:
                    self?.coordinator?.dismissFlow()
                    
                case .documentVerification, .documentVerificationRetry:
                    // try later -> dismiss flow?
                    break
                    
                default:
                    break
                }
            })
        ]
    }
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
}
