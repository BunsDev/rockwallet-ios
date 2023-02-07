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
    let canUseAch = UserManager.shared.profile?.canUseAch ?? false
    override var imageName: String? { return success?.iconName }
    override var titleText: String? { return success?.title }
    override var descriptionText: String? { return success?.description }
    override var buttonViewModels: [ButtonViewModel] {
        var buttons: [ButtonViewModel] = [
            .init(title: success?.firstButtonTitle, callback: { [weak self] in
                switch self?.success {
                case .documentVerification:
                    self?.coordinator?.showBuy(coreSystem: self?.dataStore?.coreSystem,
                                               keyStore: self?.dataStore?.keyStore)
                default:
                    self?.coordinator?.dismissFlow()
                }
            }),
            .init(title: success?.secondButtonTitle, isUnderlined: success?.secondButtonUnderlined ?? true, callback: { [weak self] in
                switch self?.success {
                case .documentVerification:
                    LoadingView.show()
                    self?.interactor?.getAssetSelectionData(viewModel: .init())
                    
                default:
                    self?.coordinator?.showExchangeDetails(with: self?.dataStore?.itemId,
                                                           type: self?.transactionType ?? .defaultTransaction)
                }
            }),
            .init(title: success?.thirdButtonTitle, isUnderlined: success?.thirdButtoUnderlined ?? true, callback: { [weak self] in
                switch self?.success {
                case .documentVerification:
                    self?.coordinator?.showBuy(type: .ach,
                                               coreSystem: self?.dataStore?.coreSystem,
                                               keyStore: self?.dataStore?.keyStore)
                default:
                    self?.coordinator?.showExchangeDetails(with: self?.dataStore?.itemId,
                                                           type: self?.transactionType ?? .defaultTransaction)
                }
            })
        ]
        if !canUseAch && success == .documentVerification {
            buttons.removeLast()
        }
        
        return buttons
    }
    
    override var buttonConfigurations: [ButtonConfiguration] {
        var buttons = [Presets.Button.primary,
                       success?.secondButtonConfig ?? Presets.Button.noBorders,
                       success?.thirdButtonConfig ?? Presets.Button.noBorders]
        
        if !canUseAch && success == .documentVerification {
            buttons.removeLast()
        }
        
        return buttons
    }
    
    override func displayAssetSelectionData(responseDisplay: BaseInfoModels.Assets.ResponseDisplay) {
        LoadingView.hide()
        guard let coordinator = coordinator as? KYCCoordinator else { return }
        coordinator.showAssetSelector(title: responseDisplay.title ?? "",
                                                            currencies: responseDisplay.currencies,
                                                            supportedCurrencies: responseDisplay.supportedCurrencies) { selectedCurrency in
            guard let model = selectedCurrency as? AssetViewModel,
                    let currency = Store.state.currencies.first(where: { $0.code == model.subtitle }) else { return }
            let wallet = Store.state.wallets[currency.uid]?.wallet
            let accountViewController = AccountViewController(currency: currency, wallet: wallet)
            coordinator.navigationController.pushViewController(accountViewController, animated: true)
        }
    }
}
