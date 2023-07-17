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
    
    private var amount: Amount? {
        get {
            return dataStore?.toAmount
        }
        set(value) {
            dataStore?.toAmount = value
        }
    }
    
    // MARK: - BuyViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        let item = AssetModels.Item(type: dataStore?.paymentMethod,
                                    achEnabled: UserManager.shared.profile?.kycAccessRights.hasAchAccess ?? false)
        
        prepareCurrencies(viewAction: item)
        
        guard !(dataStore?.supportedCurrencies ?? []).isEmpty else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.selectAssets))
            return
        }
        
        if dataStore?.selected == nil {
            presenter?.presentData(actionResponse: .init(item: item))
            setAmount(viewAction: .init(currency: amount?.currency.code ?? dataStore?.currencies.first?.code))
        }
        
        dataStore?.selected = dataStore?.paymentMethod == .ach ? dataStore?.ach : (dataStore?.selected ?? dataStore?.cards.first)
        selectPaymentMethod(viewAction: .init(method: dataStore?.selected?.type ?? .card))
    }
    
    func achSuccessMessage(viewAction: PaymentMethodsModels.Get.ViewAction) {
        let isRelinking = dataStore?.selected?.status == .requiredLogin
        presenter?.presentAchSuccess(actionResponse: .init(isRelinking: isRelinking))
        
        selectPaymentMethod(viewAction: .init(method: .ach))
    }
    
    func setAmount(viewAction: AssetModels.Asset.ViewAction) {
        if let value = viewAction.currency?.lowercased(),
           let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == value }) {
            amount = .zero(currency)
            
            guard viewAction.didFinish else { return }
            getExchangeRate(viewAction: .init(getFees: false), completion: { [weak self] in
                self?.setPresentAmountData(handleErrors: false)
            })
            
            return
        } else if let value = viewAction.card {
            dataStore?.selected = value
            
            guard viewAction.didFinish else { return }
            getExchangeRate(viewAction: .init(getFees: false), completion: { [weak self] in
                self?.setPresentAmountData(handleErrors: false)
            })
            
            return
        }
        
        guard let rate = dataStore?.quote?.exchangeRate,
              let toCurrency = amount?.currency else {
            setPresentAmountData(handleErrors: true)
            return
        }
        
        let to: Amount
        
        if let value = viewAction.fromTokenValue,
           let crypto = ExchangeFormatter.current.number(from: value)?.decimalValue {
            to = .init(decimalAmount: crypto, isFiat: false, currency: toCurrency, exchangeRate: 1 / rate)
        } else if let value = viewAction.fromFiatValue,
                  let fiat = ExchangeFormatter.current.number(from: value)?.decimalValue {
            to = .init(decimalAmount: fiat, isFiat: true, currency: toCurrency, exchangeRate: 1 / rate)
        } else {
            setPresentAmountData(handleErrors: true)
            return
        }
        
        amount = to
        dataStore?.from = to.fiatValue
        
        setPresentAmountData(handleErrors: false)
    }
    
    private func setPresentAmountData(handleErrors: Bool) {
        let isNotZero = !(amount?.tokenValue ?? 0).isZero
        
        presenter?.presentAmount(actionResponse: .init(fromAmount: amount,
                                                       card: dataStore?.selected,
                                                       type: dataStore?.paymentMethod,
                                                       quote: dataStore?.quote,
                                                       handleErrors: handleErrors && isNotZero))
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
        
        getPayments(viewAction: .init(), completion: { [weak self] in
            switch viewAction.method {
            case .ach:
                self?.dataStore?.selected = self?.dataStore?.ach
                
            case .card:
                self?.dataStore?.selected = self?.dataStore?.cards.first
                
            }
        })
        
        let item = AssetModels.Item(type: dataStore?.paymentMethod,
                                    achEnabled: UserManager.shared.profile?.kycAccessRights.hasAchAccess ?? false)
        prepareCurrencies(viewAction: item)
        
        guard let supportedCurrencies = dataStore?.supportedCurrencies, !supportedCurrencies.isEmpty else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.selectAssets))
            return
        }
        
        guard let currency = supportedCurrencies.contains(amount?.currency.code.lowercased() ?? "") ? amount?.currency : dataStore?.currencies.first else { return }
        amount = .zero(currency)
        
        getExchangeRate(viewAction: .init(getFees: false), completion: { [weak self] in
            self?.setAmount(viewAction: .init(currency: currency.code))
            
            self?.setPresentAmountData(handleErrors: false)
        })
    }
    
    func retryPaymentMethod(viewAction: BuyModels.RetryPaymentMethod.ViewAction) {
        var selectedCurrency: Amount?
        
        switch viewAction.method {
        case .card:
            if dataStore?.availablePayments.contains(.card) == true {
                guard let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == dataStore?.toCode.lowercased() }) else { return }
                selectedCurrency = .zero(currency)
            }
            
        default:
            break
        }
        
        dataStore?.paymentMethod = viewAction.method
        amount = selectedCurrency == nil ? amount : selectedCurrency
        
        presenter?.presentMessage(actionResponse: .init(method: viewAction.method))
        
        getExchangeRate(viewAction: .init(getFees: false), completion: { [weak self] in
            self?.setPresentAmountData(handleErrors: false)
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
    
    // MARK: - Additional helpers
}
