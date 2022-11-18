//
//  BuyPresenter.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//
//

import UIKit

final class BuyPresenter: NSObject, Presenter, BuyActionResponses {
    typealias Models = BuyModels

    weak var viewController: BuyViewController?
    private var exchangeRateViewModel: ExchangeRateViewModel = .init()
    private var paymentMethod: FESegmentControl.Values?

    // MARK: - BuyActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Sections] = [
            .segment,
            .rateAndTimer,
            .from,
            .paymentMethod,
            .accountLimits
        ]
        
        exchangeRateViewModel = ExchangeRateViewModel(timer: TimerViewModel(), showTimer: false)
        let paymentSegment = SegmentControlViewModel(selectedIndex: .bankAccount)
        
        let paymentMethodViewModel: CardSelectionViewModel
        switch paymentSegment.selectedIndex {
        case .bankAccount:
            paymentMethodViewModel = CardSelectionViewModel(title: .text(L10n.Buy.achPayments),
                                                   subtitle: .text(L10n.Buy.linkBankAccount),
                                                   userInteractionEnabled: true)
        default:
            paymentMethodViewModel = CardSelectionViewModel()
        }

        let sectionRows: [Models.Sections: [ViewModel]] =  [
            .segment: [paymentSegment],
            .rateAndTimer: [exchangeRateViewModel],
            .from: [SwapCurrencyViewModel(title: .text(L10n.Swap.iWant))],
            .paymentMethod: [paymentMethodViewModel],
            .accountLimits: [
                LabelViewModel.text("")
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    func presentExchangeRate(actionResponse: BuyModels.Rate.ActionResponse) {
        guard let from = actionResponse.from,
              let to = actionResponse.to,
              let quote = actionResponse.quote else {
            return
        }
        
        let text = String(format: "1 %@ = %@ %@", to.uppercased(), ExchangeFormatter.fiat.string(for: 1 / quote.exchangeRate) ?? "", from)
        let minText = ExchangeFormatter.fiat.string(for: quote.minimumValue) ?? ""
        let maxText = ExchangeFormatter.fiat.string(for: quote.maximumValue) ?? ""
        let limitText = paymentMethod == .bankAccount ? L10n.Buy.achLimits : String(format: L10n.Buy.buyLimits(minText, maxText))
        
        exchangeRateViewModel = ExchangeRateViewModel(exchangeRate: text,
                                                      timer: TimerViewModel(till: quote.timestamp,
                                                                            repeats: false),
                                                      showTimer: false)
        
        viewController?.displayExchangeRate(responseDisplay: .init(rate: exchangeRateViewModel,
                                                                   limits: .text(limitText)))
    }
    
    func presentAssets(actionResponse: BuyModels.Assets.ActionResponse) {
        paymentMethod = actionResponse.paymentMethod
        var cryptoModel: SwapCurrencyViewModel
        let cardModel: CardSelectionViewModel
        
        let fromFiatValue = actionResponse.amount?.fiatValue == 0 ? nil : ExchangeFormatter.fiat.string(for: actionResponse.amount?.fiatValue)
        let fromTokenValue = actionResponse.amount?.tokenValue == 0 ? nil : ExchangeFormatter.crypto.string(for: actionResponse.amount?.tokenValue)
        
        let formattedFiatString = ExchangeFormatter.createAmountString(string: fromFiatValue ?? "")
        let formattedTokenString = ExchangeFormatter.createAmountString(string: fromTokenValue ?? "")
        
        cryptoModel = .init(amount: actionResponse.amount,
                            formattedFiatString: formattedFiatString,
                            formattedTokenString: formattedTokenString,
                            title: .text(L10n.Swap.iWant))
        
        if let paymentCard = actionResponse.card, actionResponse.paymentMethod == .card {
            cardModel = .init(logo: paymentCard.displayImage,
                              cardNumber: .text(paymentCard.displayName),
                              expiration: .text(CardDetailsFormatter.formatExpirationDate(month: paymentCard.expiryMonth, year: paymentCard.expiryYear)),
                              userInteractionEnabled: true)
        } else if let paymentCard = actionResponse.card, actionResponse.paymentMethod == .bankAccount {
            cardModel = .init(title: .text(L10n.Buy.achPayments),
                              logo: .imageName("bank"),
                              cardNumber: .text(paymentCard.displayBankName),
                              userInteractionEnabled: false)
            cryptoModel.selectionDisabled = true
        } else if actionResponse.paymentMethod == .card {
            cardModel = .init(userInteractionEnabled: true)
        } else {
            cardModel = CardSelectionViewModel(title: .text(L10n.Buy.achPayments),
                                               subtitle: .text(L10n.Buy.linkBankAccount),
                                               userInteractionEnabled: true)
            cryptoModel.selectionDisabled = true
        }
        viewController?.displayAssets(responseDisplay: .init(cryptoModel: cryptoModel, cardModel: cardModel))
        presentLimits(quote: actionResponse.quote)
        
        guard actionResponse.handleErrors else { return }
        handleError(actionResponse: actionResponse)
    }
    
    private func presentLimits(quote: Quote?) {
        guard let quote = quote else { return }
        let minText = ExchangeFormatter.fiat.string(for: quote.minimumValue) ?? ""
        let maxText = ExchangeFormatter.fiat.string(for: quote.maximumValue) ?? ""
        
        let limitText = paymentMethod == .bankAccount ? L10n.Buy.achLimits : String(format: L10n.Buy.buyLimits(minText, maxText))
        
        viewController?.displayExchangeRate(responseDisplay: .init(rate: exchangeRateViewModel,
                                                                   limits: .text(limitText)))
    }
    
    private func handleError(actionResponse: BuyModels.Assets.ActionResponse) {
        let fiat = (actionResponse.amount?.fiatValue ?? 0).round(to: 2)
        let minimumAmount = actionResponse.quote?.minimumUsd ?? 0
        let maximumAmount = actionResponse.quote?.maximumUsd ?? 0
        
        switch fiat {
        case _ where fiat <= 0:
            // Fiat value is below 0
            presentError(actionResponse: .init(error: nil))
            
        case _ where fiat < minimumAmount,
                            _ where minimumAmount > maximumAmount:
            // Value below minimum Fiat
            presentError(actionResponse: .init(error: BuyErrors.tooLow(amount: minimumAmount, currency: C.usdCurrencyCode)))
            
        case _ where fiat > maximumAmount:
            // Over exchange limit ???
            presentError(actionResponse: .init(error: BuyErrors.tooHigh(amount: maximumAmount, currency: C.usdCurrencyCode)))
            
        default:
            // Remove error
            presentError(actionResponse: .init(error: nil))
        }
    }
    
    private func presentAchData(actionResponse: BuyModels.Assets.ActionResponse) {
        
    }
    
    private func presentCardData(actionResponse: BuyModels.Assets.ActionResponse) {
        
    }
    
    func presentPaymentCards(actionResponse: BuyModels.PaymentCards.ActionResponse) {
        viewController?.displayPaymentCards(responseDisplay: .init(allPaymentCards: actionResponse.allPaymentCards))
    }
    
    func presentOrderPreview(actionResponse: BuyModels.OrderPreview.ActionResponse) {
        viewController?.displayOrderPreview(responseDisplay: .init())
    }
    
    func presentNavigateAssetSelector(actionResponse: BuyModels.AssetSelector.ActionResponse) {
        viewController?.displayNavigateAssetSelector(responseDisplay: .init(title: L10n.Swap.iWant))
    }
    
    func presentLinkToken(actionResponse: BuyModels.PlaidLinkToken.ActionResponse) {
        viewController?.displayLinkToken(responseDisplay: .init(linkToken: actionResponse.linkToken))
    }
    
    func presentPublicTokenSuccess(actionResponse: BuyModels.PlaidPublicToken.ActionResponse) {
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(L10n.Buy.achSuccess)),
                                                              config: Presets.InfoView.verification))
    }
    
    func presentFailure(actionResponse: BuyModels.Failure.ActionResponse) {
        viewController?.displayFailure(responseDisplay: .init())
    }
    
    func presentError(actionResponse: MessageModels.Errors.ActionResponse) {
        guard !isAccessDenied(error: actionResponse.error) else { return }
        
        guard let error = actionResponse.error as? FEError else {
            viewController?.displayMessage(responseDisplay: .init())
            return
        }
        
        let model = InfoViewModel(description: .text(error.errorMessage), dismissType: .auto)
        let config = Presets.InfoView.error
        
        viewController?.displayMessage(responseDisplay: .init(error: error, model: model, config: config))
    }
    
    // MARK: - Additional Helpers

}
