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
    
    private var amount: Amount? {
        get {
            return dataStore?.fromAmount
        }
        set(value) {
            dataStore?.fromAmount = value
        }
    }
    
    // MARK: - SellViewActions
    
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
        }
        
        getPayments(viewAction: .init()) { [weak self] in
            self?.dataStore?.selected = self?.dataStore?.ach
            self?.setAmount(viewAction: .init(currency: self?.amount?.currency.code ?? self?.dataStore?.currencies.first?.code, didFinish: true))
        }
    }
    
    func prepareFees(viewAction: AssetModels.Fee.ViewAction, completion: (() -> Void)?) {
        guard let from = amount,
              let profile = UserManager.shared.profile else {
            return
        }
        
        generateSender(viewAction: .init(fromAmountCurrency: amount?.currency))
        
        getFees(viewAction: .init(fromAmount: from, limit: profile.sellAllowanceLifetime), completion: { [weak self] _ in
            self?.setPresentAmountData(handleErrors: true)
            
            completion?()
        })
    }
    
    private func setPresentAmountData(handleErrors: Bool) {
        let isNotZero = !(dataStore?.fromAmount?.tokenValue ?? 0).isZero
        
        presenter?.presentAmount(actionResponse: .init(fromAmount: amount,
                                                       card: dataStore?.selected,
                                                       type: dataStore?.paymentMethod,
                                                       fromFee: dataStore?.fromFeeAmount,
                                                       senderValidationResult: dataStore?.senderValidationResult,
                                                       fromFeeBasis: dataStore?.fromFeeBasis,
                                                       fromFeeAmount: dataStore?.fromFeeAmount,
                                                       fromFeeCurrency: dataStore?.sender?.wallet.feeCurrency,
                                                       quote: dataStore?.quote,
                                                       handleErrors: handleErrors && isNotZero))
    }
    
    func achSuccessMessage(viewAction: PaymentMethodsModels.Get.ViewAction) {
        let isRelinking = dataStore?.selected?.status == .requiredLogin
        presenter?.presentAchSuccess(actionResponse: .init(isRelinking: isRelinking))
        
        getExchangeRate(viewAction: .init(getFees: false), completion: { [weak self] in
            self?.setPresentAmountData(handleErrors: false)
        })
    }
    
    func setAmount(viewAction: AssetModels.Asset.ViewAction) {
        if let value = viewAction.currency?.lowercased(),
           let currency = dataStore?.currencies.first(where: { $0.code.lowercased() == value }) {
            amount = .zero(currency)
            
            prepareFees(viewAction: .init(), completion: {})
            
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
        
        if let fiat = ExchangeFormatter.current.number(from: viewAction.toFiatValue ?? "")?.decimalValue {
            to = .init(decimalAmount: fiat, isFiat: true, currency: toCurrency, exchangeRate: rate)
        } else if let crypto = ExchangeFormatter.current.number(from: viewAction.fromTokenValue ?? "")?.decimalValue {
            to = .init(decimalAmount: crypto, isFiat: false, currency: toCurrency, exchangeRate: rate)
        } else {
            setPresentAmountData(handleErrors: true)
            return
        }
        
        amount = to
        
        if let xrpErrorMessage = XRPBalanceValidator.validate(balance: dataStore?.fromAmount?.currency.state?.balance,
                                                              amount: dataStore?.fromAmount,
                                                              currency: dataStore?.fromAmount?.currency) {
            presenter?.presentError(actionResponse: .init(error: GeneralError(errorMessage: xrpErrorMessage)))
            return
        }
        
        setPresentAmountData(handleErrors: false)
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
    
//    guard let address = dataStore?.ach?.id,
//          let from = dataStore?.fromAmount?.tokenValue,
//          let to = dataStore?.toAmount else {
//        return
//    }
//
//    let formatter = ExchangeFormatter.current
//    formatter.locale = Locale(identifier: Constant.usLocaleCode)
//    formatter.usesGroupingSeparator = false
//
//    let fromTokenValue = formatter.string(for: from) ?? ""
//    let toTokenValue = formatter.string(for: to) ?? ""
//
//    let data = AchExchangeRequestData(quoteId: dataStore?.quote?.quoteId,
//                                      depositQuantity: fromTokenValue,
//                                      withdrawalQuantity: toTokenValue,
//                                      accountId: address)
//
//    AchExchangeWorker().execute(requestData: data) { [weak self] result in
//        switch result {
//        case .success(let data):
//            self?.dataStore?.exchange = data
//            self?.createTransaction(viewAction: .init(exchange: self?.dataStore?.exchange,
//                                                      currencies: self?.dataStore?.currencies,
//                                                      fromFeeAmount: self?.dataStore?.fromFeeAmount,
//                                                      fromAmount: self?.dataStore?.fromAmount,
//                                                      toAmountCode: self?.dataStore?.toCode), completion: { [weak self] error in
//                guard error == nil else {
//                    self?.presenter?.presentError(actionResponse: .init(error: error))
//                    return
//                }
//
//                self?.dataStore?.availablePayments = []
//                let containsDebitCard = self?.dataStore?.cards.first(where: { $0.cardType == .debit }) != nil
//
//                if self?.dataStore?.selected?.cardType == .credit, containsDebitCard {
//                    self?.dataStore?.availablePayments.append(.card)
//                }
//
//                if self?.dataStore?.selected?.cardType == .debit, self?.dataStore?.paymentMethod == .card, self?.dataStore?.ach != nil {
//                    self?.dataStore?.availablePayments.append(.ach)
//                }
//
//                self?.presenter?.presentOrderPreview(actionResponse: .init(availablePayments: self?.dataStore?.availablePayments))
//
//            })
//
//        case .failure(let error):
//            self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.failed(error: error)))
//        }
//    }
    
    func navigateAssetSelector(viewAction: SellModels.AssetSelector.ViewAction) {
        presenter?.presentNavigateAssetSelector(actionResponse: .init())
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
