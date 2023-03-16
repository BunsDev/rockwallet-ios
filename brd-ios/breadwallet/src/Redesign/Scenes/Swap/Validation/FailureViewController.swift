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
protocol SimpleMessage: Equatable {
    var iconName: String { get }
    var title: String { get }
    var description: String { get }
    var firstButtonTitle: String? { get }
    var secondButtonTitle: String? { get }
}

enum FailureReason: SimpleMessage {
    case buyCard
    case buyAch(String)
    case swap
    case plaidConnection
    case sell
    case documentVerification
    case documentVerificationRetry
    case limitsAuthentication
    
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
        case .buyCard, .buyAch:
            return L10n.Buy.errorProcessingPayment
            
        case .swap, .sell:
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
        case .buyCard:
            return L10n.Buy.failureTransactionMessage
            
        case .swap:
            return L10n.Swap.failureSwapMessage
            
        case .plaidConnection:
            return L10n.Buy.plaidErrorDescription
            
        case .buyAch(let message):
            return message
            
        case .sell:
            return L10n.Sell.tryAgain
            
        case .documentVerification:
            return L10n.Account.IdVerificationRejected.description
            
        case .documentVerificationRetry:
            return L10n.Account.idVerificationRetry.replacingOccurrences(of: "-", with: "\u{2022}")
            
        case .limitsAuthentication:
            return L10n.Account.VerificationUnsuccessful.description.replacingOccurrences(of: "-", with: "\u{2022}")
        }
    }
    
    var firstButtonTitle: String? {
        switch self {
        case .swap:
            return L10n.Swap.retry
            
        case .documentVerification:
            return L10n.Account.contactUs
            
        default:
            return L10n.PaymentConfirmation.tryAgain
        }
    }
    
    var secondButtonTitle: String? {
        switch self {
        case .swap:
            return L10n.Swap.backToHome
            
        case .documentVerification, .documentVerificationRetry, .limitsAuthentication:
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
    private var veriffKYCManager: VeriffKYCManager?
    
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
                self?.shouldDismiss = true
                
                switch self?.failure {
                case .swap:
                    self?.coordinator?.popToRoot()
                    
                case .documentVerification:
                    self?.coordinator?.showSupport()
                    
                case .documentVerificationRetry:
                    self?.veriffKYCManager = VeriffKYCManager(navigationController: self?.coordinator?.navigationController)
                    self?.veriffKYCManager?.showExternalKYC { [weak self] result in
                        self?.coordinator?.handleVeriffKYC(result: result, for: .kyc)
                    }
                    
                case .limitsAuthentication:
                    LoadingView.show()
                    self?.veriffKYCManager = VeriffKYCManager(navigationController: self?.coordinator?.navigationController)
                    let requestData = VeriffSessionRequestData(quoteId: nil, isBiometric: true, biometricType: .pendingLimits)
                    self?.veriffKYCManager?.showExternalKYCForLivenessCheck(livenessCheckData: requestData) { [weak self] result in
                        switch result.status {
                        case .done:
                            BiometricStatusHelper.shared.checkBiometricStatus(resetCounter: true) { error in
                                self?.handleBiometricStatus(approved: error == nil)
                            }
                            
                        default:
                            self?.handleBiometricStatus(approved: false)
                        }
                    }
                    
                default:
                    if containsDebit || containsBankAccount {
                        self?.coordinator?.showBuyWithDifferentPayment(paymentMethod: containsDebit ? .card : .ach)
                    } else {
                        self?.coordinator?.popToRoot()
                    }
                }},
            .init(title: failure?.secondButtonTitle, isUnderlined: true, callback: { [weak self] in
                self?.shouldDismiss = true
                
                switch self?.failure {
                case .buyCard, .swap:
                    self?.coordinator?.dismissFlow()

                case .documentVerification, .documentVerificationRetry:
                    self?.coordinator?.showSupport()
                    
                case .limitsAuthentication:
                    self?.coordinator?.popToRoot()
                    
                default:
                    break
                }
            })
        ]
    }
    
    private func handleBiometricStatus(approved: Bool) {
        LoadingView.hideIfNeeded()
        guard approved else {
            coordinator?.open(scene: Scenes.Failure) { vc in
                vc.failure = .limitsAuthentication
                vc.navigationItem.hidesBackButton = true
                vc.navigationItem.rightBarButtonItem = nil
            }
            return
        }
        
        coordinator?.open(scene: Scenes.Success) { vc in
            vc.success = .limitsAuthentication
            vc.navigationItem.hidesBackButton = true
            vc.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
    
    override func tableView(_ tableView: UITableView, descriptionLabelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Align text to left for retry bullet points text
        guard failure == .documentVerificationRetry else {
            return super.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
        }
        
        guard let value = descriptionText,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }

        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.two, textColor: LightColors.Text.two, textAlignment: .left))
            view.setup(with: .text(value))
            view.setupCustomMargins(vertical: .extraHuge, horizontal: .extraHuge)
            view.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(Margins.extraHuge.rawValue)
            }
        }

        return cell
    }
}
