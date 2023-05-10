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
        presenter?.presentAssets(actionResponse: .init(amount: dataStore?.fromAmount,
                                                       card: dataStore?.selected,
                                                       type: dataStore?.paymentMethod,
                                                       quote: dataStore?.quote))
        getPayments(viewAction: .init())
    }
    
    func didGetPayments(viewAction: AchPaymentModels.Get.ViewAction) {
        if viewAction.openCards == true {
            presenter?.presentPaymentCards(actionResponse: .init(allPaymentCards: dataStore?.cards ?? []))
        } else {
            dataStore?.selected = dataStore?.paymentMethod == .ach ? dataStore?.ach : dataStore?.cards.first
            setAssets(viewAction: .init(card: dataStore?.selected))
        }
    }
    
    func achSuccessMessage(viewAction: AchPaymentModels.Get.ViewAction) {
        let isRelinking = dataStore?.selected?.status == .requiredLogin
        presenter?.presentAchSuccess(actionResponse: .init(isRelinking: isRelinking))
    }
    
    func setAmount(viewAction: SellModels.Amounts.ViewAction) {
        guard let rate = dataStore?.quote?.exchangeRate,
              let toCurrency = dataStore?.fromAmount?.currency else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noQuote(from: Constant.usdCurrencyCode,
                                                                                        to: dataStore?.fromAmount?.currency.code)))
            return
        }
                
        dataStore?.values = viewAction
        
        let to: Amount
        
        if let value = viewAction.tokenValue,
           let crypto = ExchangeFormatter.current.number(from: value)?.decimalValue {
            to = .init(decimalAmount: crypto, isFiat: false, currency: toCurrency, exchangeRate: 1 / rate)
        } else if let value = viewAction.fiatValue,
                  let fiat = ExchangeFormatter.current.number(from: value)?.decimalValue {
            to = .init(decimalAmount: fiat, isFiat: true, currency: toCurrency, exchangeRate: 1 / rate)
        } else {
            presenter?.presentAssets(actionResponse: .init(amount: dataStore?.fromAmount,
                                                           card: dataStore?.selected,
                                                           type: dataStore?.paymentMethod,
                                                           quote: dataStore?.quote,
                                                           handleErrors: true))
            return
        }
        
        dataStore?.fromAmount = to
//        dataStore?.from = to.fiatValue
        
        presenter?.presentAssets(actionResponse: .init(amount: dataStore?.fromAmount,
                                                       card: dataStore?.selected,
                                                       type: dataStore?.paymentMethod,
                                                       quote: dataStore?.quote))
    }
    
    func setAssets(viewAction: SellModels.Assets.ViewAction) {
        if let value = viewAction.currency?.lowercased(),
           let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == value }) {
            dataStore?.fromAmount = .zero(currency)
        } else if let value = viewAction.card {
            dataStore?.selected = value
        }
        
        getExchangeRate(viewAction: .init(), completion: { [weak self] in
            self?.presenter?.presentAssets(actionResponse: .init(amount: self?.dataStore?.fromAmount,
                                                                 card: self?.dataStore?.selected,
                                                                 type: self?.dataStore?.paymentMethod,
                                                                 quote: self?.dataStore?.quote))
        })
    }
    
    func showOrderPreview(viewAction: SellModels.OrderPreview.ViewAction) {
        dataStore?.availablePayments = []
        let containsDebitCard = dataStore?.cards.first(where: { $0.cardType == .debit }) != nil
        
        if dataStore?.selected?.cardType == .credit,
            containsDebitCard {
            dataStore?.availablePayments.append(.card)
        }
        
        if dataStore?.selected?.cardType == .debit,
           dataStore?.paymentMethod == .card,
           dataStore?.ach != nil {
            dataStore?.availablePayments.append(.ach)
        }
        
        presenter?.presentOrderPreview(actionResponse: .init(availablePayments: dataStore?.availablePayments))
    }
    
    func navigateAssetSelector(viewAction: SellModels.AssetSelector.ViewAction) {
        presenter?.presentNavigateAssetSelector(actionResponse: .init())
    }
    
    func selectPaymentMethod(viewAction: SellModels.PaymentMethod.ViewAction) {
        dataStore?.paymentMethod = viewAction.method
        switch viewAction.method {
        case .ach:
            dataStore?.selected = dataStore?.ach
            
        case .card:
            dataStore?.selected = dataStore?.cards.first
            
        }
        
        getExchangeRate(viewAction: .init(), completion: { [weak self] in
            self?.presenter?.presentAssets(actionResponse: .init(amount: self?.dataStore?.fromAmount,
                                                                 card: self?.dataStore?.selected,
                                                                 type: self?.dataStore?.paymentMethod,
                                                                 quote: self?.dataStore?.quote))
        })
    }
    
    func retryPaymentMethod(viewAction: SellModels.RetryPaymentMethod.ViewAction) {
        var selectedCurrency: Amount?
        
        switch viewAction.method {
        case .ach:
            dataStore?.selected = dataStore?.ach
            presenter?.presentMessage(actionResponse: .init(method: viewAction.method))
            
        case .card:
            if dataStore?.availablePayments.contains(.card) == true {
                dataStore?.selected = dataStore?.cards.first(where: { $0.cardType == .debit })
                guard let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == dataStore?.toCode.lowercased() }) else { return }
                selectedCurrency = .zero(currency)
            } else {
                dataStore?.selected = dataStore?.cards.first
            }
            
            presenter?.presentMessage(actionResponse: .init(method: viewAction.method))
            
        }
        
        dataStore?.paymentMethod = viewAction.method
        dataStore?.fromAmount = selectedCurrency == nil ? dataStore?.fromAmount : selectedCurrency
        
        getExchangeRate(viewAction: .init(), completion: { [weak self] in
            self?.presenter?.presentAssets(actionResponse: .init(amount: self?.dataStore?.fromAmount,
                                                                 card: self?.dataStore?.selected,
                                                                 type: self?.dataStore?.paymentMethod,
                                                                 quote: self?.dataStore?.quote))
        })
    }
    
    func showLimitsInfo(viewAction: SellModels.LimitsInfo.ViewAction) {
        presenter?.presentLimitsInfo(actionResponse: .init(paymentMethod: dataStore?.paymentMethod))
    }
    
    func showInstantAchPopup(viewAction: SellModels.InstantAchPopup.ViewAction) {
        presenter?.presentInstantAchPopup(actionResponse: .init())
    }
    
    func showAssetSelectionMessage(viewAction: SellModels.AssetSelectionMessage.ViewAction) {
        presenter?.presentAssetSelectionMessage(actionResponse: .init())
    }
    
    // MARK: - Additional helpers
}
