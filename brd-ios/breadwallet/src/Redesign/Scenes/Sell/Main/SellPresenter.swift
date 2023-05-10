//
//  SellPresenter.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

final class SellPresenter: NSObject, Presenter, SellActionResponses {
    
    typealias Models = SellModels
    
    weak var viewController: SellViewController?
    
    var achPaymentModel: CardSelectionViewModel?
    private var exchangeRateViewModel: ExchangeRateViewModel = .init()
    
    // MARK: - SellActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [ExchangeModels.Section] = [
            .rateAndTimer,
            .swapCard,
            .paymentMethod,
            .accountLimits,
            .increaseLimits
        ]
        
        exchangeRateViewModel = ExchangeRateViewModel(timer: TimerViewModel(), showTimer: false)
        
        let selectedPaymentType = PaymentCard.PaymentType.allCases.firstIndex(where: { $0 == item.type })
        
        let paymentSegment = SegmentControlViewModel(selectedIndex: selectedPaymentType,
                                                     segments: [.init(image: nil, title: L10n.Buy.buyWithCard),
                                                                .init(image: nil, title: L10n.Buy.buyWithAch)])
        let limitsString = NSMutableAttributedString(string: L10n.Buy.increaseYourLimits)
        limitsString.addAttribute(.underlineStyle, value: 1, range: NSRange.init(location: 0, length: limitsString.length))
        
        let paymentMethodViewModel: CardSelectionViewModel
        if item.type == .ach && item.achEnabled == true {
            paymentMethodViewModel = CardSelectionViewModel(title: .text(L10n.Buy.achPayments),
                                                            subtitle: .text(L10n.Buy.linkBankAccount),
                                                            userInteractionEnabled: true)
        } else {
            paymentMethodViewModel = CardSelectionViewModel()
        }
        
        let sectionRows: [ExchangeModels.Section: [any Hashable]] = [
            .rateAndTimer: [
                exchangeRateViewModel
            ],
            .swapCard: [
                MainSwapViewModel(from: .init(amount: .zero(Currencies.shared.btc!),
                                              formattedTokenString: .init(string: ""),
                                              title: .text("I have 10.12000473 USDC"),
                                              selectionDisabled: false),
                                  
                                  to: .init(currencyCode: Constant.usdCurrencyCode,
                                            currencyImage: Asset.us.image,
                                            formattedTokenString: .init(string: ""),
                                            title: .text("I receive"),
                                            selectionDisabled: true))
            ],
            .paymentMethod: [
                achPaymentModel ?? paymentMethodViewModel
            ],
            .accountLimits: [
                LabelViewModel.text("")
            ],
            .increaseLimits: [LabelViewModel.attributedText(limitsString)]
        ]
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentAssets(actionResponse: SellModels.Assets.ActionResponse) {
        var cryptoModel: MainSwapViewModel
        let cardModel: CardSelectionViewModel
        
        let fromTokenValue = actionResponse.amount?.tokenValue == 0 ? nil : ExchangeFormatter.crypto.string(for: actionResponse.amount?.tokenValue)
        let toFiatValue = actionResponse.amount?.fiatValue == 0 ? nil : ExchangeFormatter.fiat.string(for: actionResponse.amount?.fiatValue)
        
        let fromFormattedTokenString = ExchangeFormatter.createAmountString(string: fromTokenValue ?? "")
        let toFormattedFiatString = ExchangeFormatter.createAmountString(string: toFiatValue ?? "")
        
        cryptoModel = MainSwapViewModel(from: .init(amount: actionResponse.amount,
                                                    formattedTokenString: fromFormattedTokenString,
                                                    title: .text("I have 10.12000473 USDC")),
                                        
                                        to: .init(currencyCode: Constant.usdCurrencyCode,
                                                  currencyImage: Asset.us.image,
                                                  formattedTokenString: toFormattedFiatString,
                                                  title: .text("I receive")))
        
        switch actionResponse.type {
        case .ach:
            if let paymentCard = actionResponse.card {
                switch actionResponse.card?.status {
                case .statusOk:
                    cardModel = .init(title: .text(L10n.Buy.transferFromBank),
                                      subtitle: nil,
                                      logo: .image(Asset.bank.image),
                                      cardNumber: .text(paymentCard.displayName),
                                      userInteractionEnabled: false)
                    
                default:
                    cardModel = .init(title: .text(L10n.Buy.achPayments),
                                      subtitle: .text(L10n.Buy.relinkBankAccount),
                                      userInteractionEnabled: true)
                    
                    let model = InfoViewModel(description: .text(L10n.Buy.Ach.accountUnlinked),
                                              dismissType: .auto)
                    let config = Presets.InfoView.error
                    
                    viewController?.displayMessage(responseDisplay: .init(model: model,
                                                                          config: config))
                }
            } else {
                cardModel = CardSelectionViewModel(title: .text(L10n.Buy.achPayments),
                                                   subtitle: .text(L10n.Buy.linkBankAccount),
                                                   userInteractionEnabled: true)
            }
            
        default:
            if let paymentCard = actionResponse.card {
                cardModel = .init(logo: paymentCard.displayImage,
                                  cardNumber: .text(paymentCard.displayName),
                                  expiration: .text(CardDetailsFormatter.formatExpirationDate(month: paymentCard.expiryMonth, year: paymentCard.expiryYear)),
                                  userInteractionEnabled: true)
            } else {
                cardModel = .init(userInteractionEnabled: true)
            }
        }
        
        viewController?.displayAssets(responseDisplay: .init(cryptoModel: cryptoModel, cardModel: cardModel))
        
        guard actionResponse.handleErrors else { return }
//        handleError(actionResponse: actionResponse)
    }
    
    private func handleError(actionResponse: SellModels.Assets.ActionResponse) {
//        let fiat = (actionResponse.amount?.fiatValue ?? 0).round(to: 2)
//        let minimumAmount = actionResponse.quote?.minimumUsd ?? 0
//        let maximumAmount = actionResponse.quote?.maximumUsd ?? 0
//
//        let profile = UserManager.shared.profile
//        let lifetimeLimit = profile?.buyAllowanceLifetime ?? 0
//
//        switch fiat {
//        case _ where fiat <= 0:
//            // Fiat value is below 0
//            presentError(actionResponse: .init(error: nil))
//
//        case _ where fiat < minimumAmount:
//            // Value below minimum Fiat
//            presentError(actionResponse: .init(error: ExchangeErrors.tooLow(amount: minimumAmount, currency: Constant.usdCurrencyCode, reason: .buyCard(nil))))
//
//        case _ where fiat > lifetimeLimit,
//            _ where minimumAmount > lifetimeLimit:
//            // Over lifetime limit
//            let limit = profile?.buyAllowanceLifetime ?? 0
//            presentError(actionResponse: .init(error: ExchangeErrors.overLifetimeLimit(limit: limit)))
//
//        case _ where fiat > maximumAmount,
//            _ where minimumAmount > maximumAmount:
//            // Over exchange limit
//            presentError(actionResponse: .init(error: ExchangeErrors.tooHigh(amount: maximumAmount, currency: Constant.usdCurrencyCode, reason: .buyCard(nil))))
//
//        default:
//            // Remove error
//            presentError(actionResponse: .init(error: nil))
//        }
    }
    
    func presentPaymentCards(actionResponse: SellModels.PaymentCards.ActionResponse) {
        viewController?.displayPaymentCards(responseDisplay: .init(allPaymentCards: actionResponse.allPaymentCards))
    }
    
    func presentOrderPreview(actionResponse: SellModels.OrderPreview.ActionResponse) {
        viewController?.displayOrderPreview(responseDisplay: .init(availablePayments: actionResponse.availablePayments))
    }
    
    func presentNavigateAssetSelector(actionResponse: SellModels.AssetSelector.ActionResponse) {
        viewController?.displayNavigateAssetSelector(responseDisplay: .init(title: L10n.Swap.iWant))
    }
    
    func presentAchSuccess(actionResponse: SellModels.AchSuccess.ActionResponse) {
        guard let isRelinking = actionResponse.isRelinking else { return }
        
        let description = isRelinking ? L10n.Buy.achPaymentMethodRelinked : L10n.Buy.achSuccess
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(description)),
                                                              config: Presets.InfoView.verification))
    }
    
    func presentMessage(actionResponse: SellModels.RetryPaymentMethod.ActionResponse) {
        let message = actionResponse.method == .card ? L10n.Buy.switchedToDebitCard : L10n.Buy.switchedToAch
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(message)),
                                                              config: Presets.InfoView.verification))
    }
    
    func presentLimitsInfo(actionResponse: SellModels.LimitsInfo.ActionResponse) {
//        let title = actionResponse.paymentMethod == .card ? L10n.Buy.yourBuyLimits : L10n.Buy.yourAchBuyLimits
//        let profile = UserManager.shared.profile
//
//        let perTransactionLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowancePerPurchase : profile?.achAllowancePerPurchase
//        let dailyMaxLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowanceDailyMax : profile?.achAllowanceDailyMax
//        let weeklyLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowanceWeekly : profile?.achAllowanceWeekly
//        let monthlyLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowanceMonthly : profile?.achAllowanceMonthly
//
//        let perTransactionLimitText = ExchangeFormatter.crypto.string(for: perTransactionLimit) ?? ""
//        let dailyMaxLimitText = ExchangeFormatter.crypto.string(for: dailyMaxLimit) ?? ""
//        let weeklyLimitText = ExchangeFormatter.crypto.string(for: weeklyLimit) ?? ""
//        let monthlyLimitText = ExchangeFormatter.crypto.string(for: monthlyLimit) ?? ""
//
//        let config: WrapperPopupConfiguration<LimitsPopupConfiguration> = .init(wrappedView: .init())
//        let wrappedViewModel: LimitsPopupViewModel = .init(title: .text(title),
//                                                           perTransaction: .init(title: .text(L10n.Buy.perTransactionLimit),
//                                                                                 value: .text("$\(perTransactionLimitText) \(Constant.usdCurrencyCode)")),
//                                                           dailyMax: .init(title: .text(L10n.Buy.dailyMaLimits),
//                                                                           value: .text("$\(dailyMaxLimitText) \(Constant.usdCurrencyCode)")),
//                                                           weekly: .init(title: .text(L10n.Account.weekly),
//                                                                         value: .text("$\(weeklyLimitText) \(Constant.usdCurrencyCode)")),
//                                                           monthly: .init(title: .text(L10n.Account.monthly),
//                                                                          value: .text("$\(monthlyLimitText) \(Constant.usdCurrencyCode)")))
//
//        let viewModel: WrapperPopupViewModel<LimitsPopupViewModel> = .init(trailing: .init(image: Asset.close.image),
//                                                                           wrappedView: wrappedViewModel,
//                                                                           hideSeparator: true)
//
//        viewController?.displayLimitsInfo(responseDisplay: .init(config: config, viewModel: viewModel))
    }
    
    func presentInstantAchPopup(actionResponse: SellModels.InstantAchPopup.ActionResponse) {
        let model = PopupViewModel(title: .text(L10n.Buy.Ach.Instant.popupTitle),
                                   body: L10n.Buy.Ach.Instant.popupContent)
        
        viewController?.displayInstantAchPopup(responseDisplay: .init(model: model))
    }
    
    func presentAssetSelectionMessage(actionResponse: SellModels.AssetSelectionMessage.ActionResponse) {
        let message = L10n.Swap.enableAssetFirst
        let model = InfoViewModel(description: .text(message), dismissType: .auto)
        let config = Presets.InfoView.warning
        
        viewController?.displayAssetSelectionMessage(responseDisplay: .init(model: model, config: config))
    }
    
    // MARK: - Additional Helpers
    
}
