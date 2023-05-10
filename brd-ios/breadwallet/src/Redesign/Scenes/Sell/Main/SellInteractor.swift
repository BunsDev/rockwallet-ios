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
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard dataStore?.fromAmount?.currency != nil,
              dataStore?.paymentMethod != nil,
              dataStore?.supportedCurrencies?.isEmpty != false else {
            getExchangeRate(viewAction: .init(), completion: {})
            return
        }

        let currencies = SupportedCurrenciesManager.shared.supportedCurrencies
        
        guard !currencies.isEmpty else { return }
        
        dataStore?.supportedCurrencies = currencies
        dataStore?.currencies = dataStore?.currencies.filter { cur in currencies.map { $0.code }.contains(cur.code) } ?? []
        
        presenter?.presentData(actionResponse: .init(item: Models.Item(type: dataStore?.paymentMethod,
                                                                       achEnabled: UserManager.shared.profile?.kycAccessRights.hasAchAccess)))
        presenter?.presentAssets(actionResponse: .init(amount: dataStore?.toAmount,
                                                       card: dataStore?.selected,
                                                       type: dataStore?.paymentMethod,
                                                       quote: dataStore?.quote))
        getPayments(viewAction: .init())
    }
    
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
        
        presenter?.presentAmount(actionResponse: .init(from: dataStore?.fromAmount, continueEnabled: dataStore?.isFormValid ?? false))
    }
    
    func didGetPayments(viewAction: AchPaymentModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: dataStore?.currency))
    }
    
    func achSuccessMessage(viewAction: AchPaymentModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: dataStore?.currency))
    }
    
    // MARK: - Additional helpers
}
