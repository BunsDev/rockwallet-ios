//
//  SwapPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class SwapPresenter: NSObject, Presenter, SwapActionResponses {
    
    typealias Models = SwapModels
    
    weak var viewController: SwapViewController?
    
    // MARK: - SwapActionResponses
    
    private var exchangeRateViewModel = ExchangeRateViewModel(timer: TimerViewModel())
    private var mainSwapViewModel = MainSwapViewModel()
    private var fromCurrencyCode: String?
    private var toCurrencyCode: String?
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item,
              let from = item.from?.currency,
              let to = item.to?.currency else {
            viewController?.displayError(responseDisplay: .init())
            return
        }
        
        let sections: [ExchangeModels.Section] = [
            .rateAndTimer,
            .swapCard,
            .accountLimits
        ]
        
        exchangeRateViewModel = ExchangeRateViewModel(timer: TimerViewModel())
        mainSwapViewModel = MainSwapViewModel(from: .init(amount: .zero(from),
                                                                  fee: .zero(from),
                                                                  formattedTokenFeeString: nil,
                                                                  title: .text(String(format: L10n.Swap.balance(ExchangeFormatter.crypto.string(for: 0) ?? "", from.code)))),
                                                      to: .init(amount: .zero(to),
                                                                fee: .zero(to),
                                                                formattedTokenFeeString: nil,
                                                                title: .text(L10n.Buy.iWant)))
        
        let sectionRows: [ExchangeModels.Section: [any Hashable]] = [
            .rateAndTimer: [
                exchangeRateViewModel
            ],
            .accountLimits: [
                LabelViewModel.text("")
            ],
            .swapCard: [
                mainSwapViewModel
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentAmount(actionResponse: SwapModels.Amounts.ActionResponse) {
        let balance = actionResponse.baseBalance
        let balanceText = String(format: L10n.Swap.balance(ExchangeFormatter.crypto.string(for: balance?.tokenValue.doubleValue) ?? "", balance?.currency.code ?? ""))
        let receivingFee = L10n.Swap.receiveNetworkFee
        
        let fromFiatValue = actionResponse.from?.fiatValue == 0 ? nil : ExchangeFormatter.fiat.string(for: actionResponse.from?.fiatValue)
        let fromTokenValue = actionResponse.from?.tokenValue == 0 ? nil : ExchangeFormatter.crypto.string(for: actionResponse.from?.tokenValue)
        let toTokenValue = actionResponse.to?.tokenValue == 0 ? nil : ExchangeFormatter.crypto.string(for: actionResponse.to?.tokenValue)
        
        let fromFormattedFiatString = ExchangeFormatter.createAmountString(string: fromFiatValue ?? "")
        let fromFormattedTokenString = ExchangeFormatter.createAmountString(string: fromTokenValue ?? "")
        let toFormattedTokenString = ExchangeFormatter.createAmountString(string: toTokenValue ?? "")
        
        let toFee = actionResponse.toFee
        let formattedToTokenFeeString = String(format: "-%@ %@",
                                               ExchangeFormatter.crypto.string(for: toFee?.tokenValue) ?? "",
                                               toFee?.currency.code.uppercased() ?? "")
        
        mainSwapViewModel = MainSwapViewModel(from: .init(amount: actionResponse.from,
                                                          formattedFiatString: fromFormattedFiatString,
                                                          formattedTokenString: fromFormattedTokenString,
                                                          title: .text(balanceText)),
                                              to: .init(amount: actionResponse.to,
                                                        formattedTokenString: toFormattedTokenString,
                                                        fee: actionResponse.toFee,
                                                        formattedTokenFeeString: formattedToTokenFeeString,
                                                        title: .text(L10n.Buy.iWant),
                                                        feeDescription: .text(receivingFee)))
        
        // Remove presented error
        presentError(actionResponse: .init(error: nil))
        
        guard actionResponse.handleErrors else {
            if actionResponse.quote?.isMinimumImpactedByWithdrawal == true
                && (fromCurrencyCode != actionResponse.from?.currency.code || toCurrencyCode != actionResponse.to?.currency.code) {
                fromCurrencyCode = actionResponse.from?.currency.code
                toCurrencyCode = actionResponse.to?.currency.code
                
                presentError(actionResponse: .init(error: ExchangeErrors.highFees))
            }
            
            viewController?.displayAmount(responseDisplay: .init(continueEnabled: false,
                                                                 amounts: mainSwapViewModel,
                                                                 rate: exchangeRateViewModel))
            return
        }
        
        let hasError = handleError(actionResponse: actionResponse)
        let continueEnabled = (!hasError && actionResponse.fromFee != nil)
        
        viewController?.displayAmount(responseDisplay: .init(continueEnabled: continueEnabled,
                                                             amounts: mainSwapViewModel,
                                                             rate: exchangeRateViewModel))
    }
    
    private func handleError(actionResponse: SwapModels.Amounts.ActionResponse) -> Bool {
        let fromFee = actionResponse.fromFee
        
        var hasError: Bool = actionResponse.from?.fiatValue == 0
        let senderValidationResult = actionResponse.senderValidationResult ?? .ok
        
        if case .insufficientFunds = senderValidationResult {
            let value = actionResponse.fromFeeAmount?.tokenValue ?? actionResponse.quote?.fromFee?.fee ?? 0
            let error = ExchangeErrors.balanceTooLow(balance: value, currency: actionResponse.from?.currency.code ?? "")
            presentError(actionResponse: .init(error: error))
            hasError = true
        } else if case .insufficientGas = senderValidationResult {
            if actionResponse.from?.currency.isEthereum == true {
                let error = ExchangeErrors.insufficientGas
                presentError(actionResponse: .init(error: error))
                hasError = true
            } else if actionResponse.from?.currency.isERC20Token == true {
                let error = ExchangeErrors.insufficientGasERC20(currency: actionResponse.from?.currency.code ?? "")
                presentError(actionResponse: .init(error: error))
                hasError = true
            } else if let feeAmount = actionResponse.fromFeeBasis?.fee {
                let error = ExchangeErrors.notEnoughEthForFee(currency: feeAmount.currency.code)
                presentError(actionResponse: .init(error: error))
                hasError = true
            }
        } else if actionResponse.baseBalance == nil
                    || actionResponse.from?.currency.code == actionResponse.to?.currency.code {
            let first = actionResponse.from?.currency.code
            let second = actionResponse.to?.currency.code
            presentError(actionResponse: .init(error: ExchangeErrors.noQuote(from: first, to: second)))
            hasError = true
        } else if ExchangeManager.shared.canSwap(actionResponse.from?.currency) == false {
            presentError(actionResponse: .init(error: ExchangeErrors.pendingSwap))
            hasError = true
        } else if let feeAmount = fromFee,
                  let feeWallet = feeAmount.currency.wallet,
                  feeAmount.currency.isEthereum && feeAmount > feeWallet.balance {
            let error = ExchangeErrors.notEnoughEthForFee(currency: feeAmount.currency.code)
            presentError(actionResponse: .init(error: error))
            hasError = true
        } else {
            let fiatValue = (actionResponse.from?.fiatValue ?? 0).round(to: 2)
            let tokenValue = actionResponse.from?.tokenValue ?? 0
            let minimumValue = actionResponse.minimumValue ?? 0
            let minimumUsd = actionResponse.minimumUsd ?? 0
            
            let profile = UserManager.shared.profile
            let dailyLimit = profile?.swapAllowanceDaily ?? 0
            let lifetimeLimit = profile?.swapAllowanceLifetime ?? 0
            let exchangeLimit = profile?.swapAllowancePerExchange ?? 0
            
            switch (fiatValue, tokenValue) {
            case _ where fiatValue > dailyLimit:
                // Over daily limit
                let limit = dailyLimit
                let error = profile?.status == .levelTwo(.levelTwo) ? ExchangeErrors.overDailyLimitLevel2(limit: limit) : ExchangeErrors.overDailyLimit(limit: limit)
                presentError(actionResponse: .init(error: error))
                hasError = true
                
            case _ where fiatValue > lifetimeLimit:
                // Over lifetime limit
                let limit = lifetimeLimit
                presentError(actionResponse: .init(error: ExchangeErrors.overLifetimeLimit(limit: limit)))
                hasError = true
                
            case _ where fiatValue > exchangeLimit:
                // Over exchange limit
                presentError(actionResponse: .init(error: ExchangeErrors.overExchangeLimit))
                hasError = true
                
            case _ where fiatValue <= 0:
                // Fiat value is below 0
                presentError(actionResponse: .init(error: nil))
                hasError = true
                
            case _ where fiatValue > (actionResponse.baseBalance?.fiatValue ?? 0):
                // Value higher than balance
                let error = ExchangeErrors.balanceTooLow(balance: fromFee?.tokenValue ?? 0, currency: actionResponse.from?.currency.code ?? "")
                presentError(actionResponse: .init(error: error))
                hasError = true
                
            case _ where fiatValue < minimumUsd:
                // Value below minimum fiat
                presentError(actionResponse: .init(error: ExchangeErrors.tooLow(amount: minimumUsd, currency: actionResponse.from?.currency.code ?? "", reason: .swap)))
                hasError = true
                
            case _ where tokenValue < minimumValue:
                // Value below minimum crypto
                presentError(actionResponse: .init(error: ExchangeErrors.tooLow(amount: minimumValue, currency: Constant.usdCurrencyCode, reason: .swap)))
                hasError = true
                
            default:
                // Remove presented error
                presentError(actionResponse: .init(error: nil))
            }
        }
        
        return hasError
    }
    
    func presentSelectAsset(actionResponse: SwapModels.Assets.ActionResponse) {
        let title = actionResponse.from == nil ? L10n.Swap.youReceive : L10n.Swap.youSend
        
        viewController?.displaySelectAsset(responseDisplay: .init(title: title, from: actionResponse.from, to: actionResponse.to))
    }
    
    func presentConfirmation(actionResponse: SwapModels.ShowConfirmDialog.ActionResponse) {
        guard let from = actionResponse.from,
              let to = actionResponse.to,
              let rate = actionResponse.quote?.exchangeRate.doubleValue else {
            return
        }
        
        let rateText = String(format: "1 %@ = %@ %@", from.currency.code, RWFormatter().string(for: rate) ?? "", to.currency.code)
        
        let fromText = String(format: "%@ %@ (%@ %@)", ExchangeFormatter.crypto.string(for: from.tokenValue.doubleValue) ?? "",
                              from.currency.code,
                              ExchangeFormatter.fiat.string(for: from.fiatValue.doubleValue) ?? "",
                              Constant.usdCurrencyCode)
        let toText = String(format: "%@ %@",
                            ExchangeFormatter.crypto.string(for: to.tokenValue.doubleValue) ?? "",
                            to.currency.code)
        
        let toFeeText = String(format: "-%@ %@",
                               ExchangeFormatter.crypto.string(for: actionResponse.toFee?.tokenValue.doubleValue) ?? "",
                               actionResponse.toFee?.currency.code ?? to.currency.code)
        
        let totalCostText = String(format: "%@ %@", ExchangeFormatter.crypto.string(for: to.tokenValue.doubleValue) ?? "", to.currency.code)
        
        let config: WrapperPopupConfiguration<SwapConfimationConfiguration> = .init(wrappedView: .init())
        
        let wrappedViewModel: SwapConfirmationViewModel = .init(from: .init(title: .text(L10n.TransactionDetails.addressFromHeader), value: .text(fromText)),
                                                                to: .init(title: .text(L10n.TransactionDetails.addressToHeader), value: .text(toText)),
                                                                rate: .init(title: .text(L10n.Swap.rateValue), value: .text(rateText)),
                                                                receivingFee: .init(title: .text(L10n.Swap.receiveNetworkFee), value: .text(toFeeText)),
                                                                totalCost: .init(title: .text(L10n.Swap.youReceive), value: .text(totalCostText)))
        
        let viewModel: WrapperPopupViewModel<SwapConfirmationViewModel> = .init(title: .text(L10n.Confirmation.title),
                                                                                confirm: .init(title: L10n.Button.confirm),
                                                                                cancel: .init(title: L10n.Button.cancel),
                                                                                wrappedView: wrappedViewModel)
        
        viewController?.displayConfirmation(responseDisplay: .init(config: config, viewModel: viewModel))
    }
    
    func presentConfirm(actionResponse: SwapModels.Confirm.ActionResponse) {
        guard let from = actionResponse.from,
              let to = actionResponse.to,
              let exchangeId = actionResponse.exchangeId else {
            presentError(actionResponse: .init(error: GeneralError(errorMessage: L10n.Swap.notValidPair)))
            return
        }
        viewController?.displayConfirm(responseDisplay: .init(from: from, to: to, exchangeId: "\(exchangeId)"))
    }
    
    func presentAssetInfoPopup(actionResponse: SwapModels.AssetInfoPopup.ActionResponse) {
        let popupViewModel = PopupViewModel(title: .text(L10n.Swap.checkAssets),
                                            body: L10n.Swap.checkAssetsBody,
                                            buttons: [.init(title: L10n.Swap.gotItButton)])
        
        viewController?.displayAssetInfoPopup(responseDisplay: .init(popupViewModel: popupViewModel,
                                                                     popupConfig: Presets.Popup.white))
    }
    
    func presentAssetSelectionMessage(actionResponse: SwapModels.AssetSelectionMessage.ActionResponse) {
        let message: String
        if actionResponse.from?.code == actionResponse.selectedDisabledAsset?.subtitle || actionResponse.to?.code == actionResponse.selectedDisabledAsset?.subtitle {
            message = L10n.Swap.sameAssetMessage
        } else {
            message = L10n.Swap.enableAssetFirst
        }
        
        let model = InfoViewModel(description: .text(message), dismissType: .auto)
        let config = Presets.InfoView.warning
        
        viewController?.displayAssetSelectionMessage(responseDisplay: .init(model: model, config: config))
    }
    
    // MARK: - Additional Helpers
    
}
