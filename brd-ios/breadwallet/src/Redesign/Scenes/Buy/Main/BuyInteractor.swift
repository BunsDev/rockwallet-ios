//
//  BuyInteractor.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//
//

import UIKit
import WalletKit

class BuyInteractor: NSObject, Interactor, BuyViewActions {

    typealias Models = BuyModels
    
    var presenter: BuyPresenter?
    var dataStore: BuyStore?
    
    // MARK: - BuyViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard dataStore?.toAmount?.currency != nil,
              dataStore?.paymentMethod != nil,
              dataStore?.supportedCurrencies?.isEmpty != false else {
            getExchangeRate(viewAction: .init(), completion: {})
            return
        }
        
        SupportedCurrenciesWorker().execute { [weak self] result in
            switch result {
            case .success(let currencies):
                ExchangeManager.shared.reload()
                
                guard let currencies, !currencies.isEmpty else {
                    return
                }
                
                self?.dataStore?.supportedCurrencies = currencies
                self?.dataStore?.currencies = self?.dataStore?.currencies.filter { cur in currencies.map { $0.code }.contains(cur.code) } ?? []
                
                self?.presenter?.presentData(actionResponse: .init(item: Models.Item(type: self?.dataStore?.paymentMethod,
                                                                                     achEnabled: UserManager.shared.profile?.kycAccessRights.hasAchAccess)))
                self?.presenter?.presentAssets(actionResponse: .init(amount: self?.dataStore?.toAmount,
                                                                     card: self?.dataStore?.selected,
                                                                     type: self?.dataStore?.paymentMethod,
                                                                     quote: self?.dataStore?.quote))
                self?.getPayments(viewAction: .init())
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.supportedCurrencies(error: error)))
            }
        }
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
    
    func setAmount(viewAction: BuyModels.Amounts.ViewAction) {
        guard let rate = dataStore?.quote?.exchangeRate,
              let toCurrency = dataStore?.toAmount?.currency else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noQuote(from: Constant.usdCurrencyCode,
                                                                                        to: dataStore?.toAmount?.currency.code)))
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
            presenter?.presentAssets(actionResponse: .init(amount: dataStore?.toAmount,
                                                           card: dataStore?.selected,
                                                           type: dataStore?.paymentMethod,
                                                           quote: dataStore?.quote,
                                                           handleErrors: true))
            return
        }
        
        dataStore?.toAmount = to
        dataStore?.from = to.fiatValue
        
        presenter?.presentAssets(actionResponse: .init(amount: dataStore?.toAmount,
                                                       card: dataStore?.selected,
                                                       type: dataStore?.paymentMethod,
                                                       quote: dataStore?.quote))
    }
    
    func setAssets(viewAction: BuyModels.Assets.ViewAction) {
        if let value = viewAction.currency?.lowercased(),
           let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == value }) {
            dataStore?.toAmount = .zero(currency)
        } else if let value = viewAction.card {
            dataStore?.selected = value
        }
        
        getExchangeRate(viewAction: .init(), completion: { [weak self] in
            self?.presenter?.presentAssets(actionResponse: .init(amount: self?.dataStore?.toAmount,
                                                                 card: self?.dataStore?.selected,
                                                                 type: self?.dataStore?.paymentMethod,
                                                                 quote: self?.dataStore?.quote))
        })
    }
    
    func showOrderPreview(viewAction: BuyModels.OrderPreview.ViewAction) {
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
    
    func navigateAssetSelector(viewAction: BuyModels.AssetSelector.ViewAction) {
        presenter?.presentNavigateAssetSelector(actionResponse: .init())
    }
    
    func selectPaymentMethod(viewAction: BuyModels.PaymentMethod.ViewAction) {
        dataStore?.paymentMethod = viewAction.method
        switch viewAction.method {
        case .ach:
            dataStore?.selected = dataStore?.ach
            
        case .card:
            dataStore?.selected = dataStore?.cards.first
            
        }
        
        getExchangeRate(viewAction: .init(), completion: { [weak self] in
            self?.presenter?.presentAssets(actionResponse: .init(amount: self?.dataStore?.toAmount,
                                                                 card: self?.dataStore?.selected,
                                                                 type: self?.dataStore?.paymentMethod,
                                                                 quote: self?.dataStore?.quote))
        })
    }
    
    func retryPaymentMethod(viewAction: BuyModels.RetryPaymentMethod.ViewAction) {
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
        dataStore?.toAmount = selectedCurrency == nil ? dataStore?.toAmount : selectedCurrency
        
        getExchangeRate(viewAction: .init(), completion: { [weak self] in
            self?.presenter?.presentAssets(actionResponse: .init(amount: self?.dataStore?.toAmount,
                                                                 card: self?.dataStore?.selected,
                                                                 type: self?.dataStore?.paymentMethod,
                                                                 quote: self?.dataStore?.quote))
        })
    }
    
    func showLimitsInfo(viewAction: BuyModels.LimitsInfo.ViewAction) {
        presenter?.presentLimitsInfo(actionResponse: .init(paymentMethod: dataStore?.paymentMethod))
    }
    
    func showInstantAchPopup(viewAction: BuyModels.InstantAchPopup.ViewAction) {
        presenter?.presentInstantAchPopup(actionResponse: .init())
    }
    
    func showAssetSelectionMessage(viewAction: BuyModels.AssetSelectionMessage.ViewAction) {
        presenter?.presentAssetSelectionMessage(actionResponse: .init())
    }
    
    // MARK: - Aditional helpers
}
