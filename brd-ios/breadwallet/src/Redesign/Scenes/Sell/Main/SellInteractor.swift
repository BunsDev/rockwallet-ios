//
//  SellInteractor.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

class SellInteractor: NSObject, Interactor, SellViewActions {
    typealias Models = SellModels

    var presenter: SellPresenter?
    var dataStore: SellStore?

    // MARK: - SellViewActions

    func setAmount(viewAction: Models.Amounts.ViewAction) {
        guard let rate = dataStore?.quote?.exchangeRate,
              let currency = dataStore?.currency
        else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noQuote(from: dataStore?.fromCode,
                                                                                   to: dataStore?.toCode)))
            return
        }
        
        if let crypto = ExchangeFormatter.current.number(from: viewAction.from ?? "")?.decimalValue {
            dataStore?.fromAmount = .init(decimalAmount: crypto, isFiat: false, currency: currency, exchangeRate: 1 / rate)
        } else if let fiat = ExchangeFormatter.current.number(from: viewAction.to ?? "")?.decimalValue {
            dataStore?.fromAmount = .init(decimalAmount: fiat, isFiat: true, currency: currency, exchangeRate: 1 / rate)
        }
        
        presenter?.presentAmount(actionResponse: .init(from: dataStore?.fromAmount))
    }
    // MARK: - Aditional helpers
}
