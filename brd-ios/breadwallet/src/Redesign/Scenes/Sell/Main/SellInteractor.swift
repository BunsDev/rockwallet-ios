//
//  SellInteractor.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit
import WalletKit

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
        
        guard !currencies.isEmpty else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.selectAssets))
            return
        }
        
        dataStore?.supportedCurrencies = currencies
        dataStore?.currencies = dataStore?.currencies.filter { cur in currencies.map { $0.code }.contains(cur.code) } ?? []
        
        presenter?.presentData(actionResponse: .init(item: Models.Item(type: dataStore?.paymentMethod,
                                                                       achEnabled: UserManager.shared.profile?.kycAccessRights.hasAchAccess)))
        getExchangeRate(viewAction: .init(), completion: { [weak self] in
            self?.setPresentAmountData(handleErrors: false)
        })
        
        getPayments(viewAction: .init())
        
        prepareFees(viewAction: .init())
    }
    
    func prepareFees(viewAction: SellModels.Fee.ViewAction) {
        guard let from = dataStore?.fromAmount,
              let profile = UserManager.shared.profile else {
            return
        }
        
        generateSender(viewAction: .init(fromAmount: dataStore?.fromAmount,
                                         coreSystem: dataStore?.coreSystem,
                                         keyStore: dataStore?.keyStore))
        
        getFees(viewAction: .init(fromAmount: from, limit: profile.sellAllowanceLifetime), completion: { [weak self] error in
            if let error {
                self?.presenter?.presentError(actionResponse: .init(error: error))
            } else {
                self?.setPresentAmountData(handleErrors: true)
            }
        })
    }
    
    private func setPresentAmountData(handleErrors: Bool) {
        let isNotZero = !(dataStore?.fromAmount?.tokenValue ?? 0).isZero
        
        presenter?.presentAssets(actionResponse: .init(amount: dataStore?.fromAmount,
                                                       card: dataStore?.selected,
                                                       type: dataStore?.paymentMethod,
                                                       quote: dataStore?.quote,
                                                       handleErrors: handleErrors && isNotZero))
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
        
        if let fiat = ExchangeFormatter.current.number(from: viewAction.fiatValue ?? "")?.decimalValue {
            to = .init(decimalAmount: fiat, isFiat: true, currency: toCurrency, exchangeRate: rate)
        } else if let crypto = ExchangeFormatter.current.number(from: viewAction.tokenValue ?? "")?.decimalValue {
            to = .init(decimalAmount: crypto, isFiat: false, currency: toCurrency, exchangeRate: rate)
        } else {
            setPresentAmountData(handleErrors: true)
            return
        }
        
        dataStore?.fromAmount = to
        
        setPresentAmountData(handleErrors: false)
    }
    
    func setAssets(viewAction: SellModels.Assets.ViewAction) {
        if let value = viewAction.currency?.lowercased(),
           let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == value }) {
            dataStore?.fromAmount = .zero(currency)
        } else if let value = viewAction.card {
            dataStore?.selected = value
        }
        
        getExchangeRate(viewAction: .init(), completion: { [weak self] in
            self?.setPresentAmountData(handleErrors: false)
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
            self?.setPresentAmountData(handleErrors: false)
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
            self?.setPresentAmountData(handleErrors: false)
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
