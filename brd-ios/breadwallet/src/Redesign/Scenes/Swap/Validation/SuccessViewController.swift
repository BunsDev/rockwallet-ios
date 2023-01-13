// 
//  SuccessViewController.swift
//  breadwallet
//
//  Created by Rok on 12/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum SuccessReason: SimpleMessage {
    case buyCard
    case buyAch
    case sell
    case documentVerification
    
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
        }
    }
    
    var description: String {
        switch self {
        case .buyCard:
            return L10n.Buy.purchaseSuccessText
            
        case .buyAch:
            return L10n.Buy.bankAccountSuccessText
            
        case .sell:
            return L10n.Sell.withdrawalSuccessText
            
        case .documentVerification:
            return L10n.Account.startUsingWallet
        }
    }
    
    var firstButtonTitle: String? {
        switch self {
        case .documentVerification:
            return L10n.Button.buyDigitalAssets
            
        default:
            return L10n.Swap.backToHome
        }
    }
    
    var secondButtonTitle: String? {
        switch self {
        case .sell:
            return L10n.Sell.withdrawDetails
            
        case .documentVerification:
            return L10n.Button.receiveDigitalAssets
            
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
    
}

extension Scenes {
    static let Success = SuccessViewController.self
}

class SuccessViewController: BaseInfoViewController {
    var success: SuccessReason? {
        didSet {
            prepareData()
        }
    }
    
    var transactionType: TransactionType = .defaultTransaction
    override var imageName: String? { return success?.iconName }
    override var titleText: String? { return success?.title }
    override var descriptionText: String? { return success?.description }
    override var buttonViewModels: [ButtonViewModel] {
        return [
            .init(title: success?.firstButtonTitle, callback: { [weak self] in
                self?.coordinator?.dismissFlow()
            }),
            .init(title: success?.secondButtonTitle, isUnderlined: true, callback: { [weak self] in
                self?.coordinator?.showExchangeDetails(with: self?.dataStore?.itemId, type: self?.transactionType ?? .defaultTransaction)
            }),
            .init(title: success?.thirdButtonTitle, isUnderlined: true, callback: { [weak self] in
                self?.coordinator?.showExchangeDetails(with: self?.dataStore?.itemId, type: self?.transactionType ?? .defaultTransaction)
            })
        ]
    }
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders,
                Presets.Button.noBorders]
    }
}
