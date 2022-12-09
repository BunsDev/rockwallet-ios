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

    // MARK: - SellActionResponses
    func presentAmount(actionResponse: Models.Amounts.ActionResponse) {
        guard let from = actionResponse.from else { return }
        let toFiatValue = from.fiatValue == 0 ? nil : ExchangeFormatter.fiat.string(for: from.fiatValue)
        let fromTokenValue = from.tokenValue == 0 ? nil : ExchangeFormatter.crypto.string(for: from.tokenValue)

        let fromFormattedTokenString = ExchangeFormatter.createAmountString(string: fromTokenValue ?? "")
        let toFormattedFiatString = ExchangeFormatter.createAmountString(string: toFiatValue ?? "")
        
        let vm = MainSwapViewModel(from: .init(amount: from,
                                          formattedTokenString: fromFormattedTokenString,
                                          title: .text("I have 10.12000473 USDC")),
                              
                              to: .init(currencyCode: C.usdCurrencyCode,
                                        currencyImage: Asset.us.image,
                                        formattedTokenString: toFormattedFiatString,
                                        title: .text("I receive")),
                              
                             hideSwapButton: true)
        viewController?.displayAmount(responseDisplay: .init(continueEnabled: true,
                                                             amounts: vm))
    }
    // MARK: - Additional Helpers

}
