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
    
    private var sender: Sender?
    
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
    }
    
    func getCoingeckoExchangeRate(viewAction: ExchangeRateModels.CoingeckoRate.ViewAction, completion: (() -> Void)?) {
        guard let baseCurrency = dataStore?.fromAmount?.currency.coinGeckoId else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noQuote(from: dataStore?.fromCode, to: dataStore?.toCode)))
            return
        }
        
        let coinGeckoIds = [baseCurrency]
        let vsCurrency = Constant.usdCurrencyCode.lowercased()
        let resource = Resources.simplePrice(ids: coinGeckoIds,
                                             vsCurrency: vsCurrency,
                                             options: [.change]) { [weak self] (result: Result<[SimplePrice], CoinGeckoError>) in
            switch result {
            case .success(let data):
                self?.dataStore?.fromRate = Decimal(data.first(where: { $0.id == baseCurrency })?.price ?? 0)
                
                completion?()
                
                guard viewAction.getFees else {
                    self?.setPresentAmountData(handleErrors: true)
                    
                    return
                }
                
                self?.getFees(viewAction: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
                
                completion?()
            }
        }
        
        CoinGeckoClient().load(resource)
        _ = generateSender()
    }
    
    private func setPresentAmountData(handleErrors: Bool) {
        let isNotZero = !(dataStore?.fromAmount?.tokenValue ?? 0).isZero
        
        presenter?.presentAssets(actionResponse: .init(amount: dataStore?.fromAmount,
                                                       card: dataStore?.selected,
                                                       type: dataStore?.paymentMethod,
                                                       quote: dataStore?.quote,
                                                       handleErrors: handleErrors && isNotZero))
    }
    
    func getFees(viewAction: SwapModels.Fee.ViewAction) {
        guard let from = dataStore?.fromAmount,
              let fromAddress = from.currency.wallet?.defaultReceiveAddress,
              let sender else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noFees))
            
            return
        }
        
        dataStore?.senderValidationResult = nil
        
        guard let profile = UserManager.shared.profile, from.fiatValue <= profile.sellAllowanceLifetime else {
            setPresentAmountData(handleErrors: true)
            return
        }
        
        fetchWalletKitFee(for: from,
                          with: sender,
                          address: fromAddress) { [weak self] fee in
            self?.dataStore?.fromFeeBasis = fee
            
            self?.dataStore?.senderValidationResult = sender.validate(amount: from, feeBasis: self?.dataStore?.fromFeeBasis)
            self?.setPresentAmountData(handleErrors: true)
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
    
    private func generateSender() -> Sender? {
        guard let fromCurrency = dataStore?.fromAmount?.currency,
              let wallet = dataStore?.coreSystem?.wallet(for: fromCurrency),
              let keyStore = dataStore?.keyStore,
              let kvStore = Backend.kvStore else { return nil }
        
        sender = Sender(wallet: wallet, authenticator: keyStore, kvStore: kvStore)
        
        sender?.updateNetworkFees()
        
        return sender
    }
    
    private func createTransaction(from swap: Exchange?) {
        guard let dataStore = dataStore,
              let currency = dataStore.currencies.first(where: { $0.code == swap?.currency }),
              let wallet = dataStore.coreSystem?.wallet(for: currency),
              let kvStore = Backend.kvStore, let keyStore = dataStore.keyStore else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noFees))
            return
        }
        
        guard let destination = swap?.address,
              let amountValue = swap?.amount,
              let fee = dataStore.fromFeeBasis,
              let exchangeId = dataStore.swap?.exchangeId
        else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noFees))
            return
        }
        
        let sender = Sender(wallet: wallet, authenticator: keyStore, kvStore: kvStore)
        let amount = Amount(decimalAmount: amountValue, isFiat: false, currency: currency)
        let transaction = sender.createTransaction(address: destination,
                                                   amount: amount,
                                                   feeBasis: fee,
                                                   comment: nil,
                                                   exchangeId: exchangeId)
        
        var error: FEError?
        switch transaction {
        case .ok:
            sender.sendTransaction(allowBiometrics: false, exchangeId: exchangeId) { [weak self] data in
                guard let pin: String = try? keychainItem(key: KeychainKey.pin) else {
                    self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.pinConfirmation))
                    return
                }
                data(pin)
            } completion: { [weak self] result in
                defer { sender.reset() }
                
                var error: FEError?
                switch result {
                case .success:
                    ExchangeManager.shared.reload()
                    
                    let from = self?.dataStore?.from?.currency.code
                    let to = self?.dataStore?.to?.currency.code
                    
                    self?.presenter?.presentConfirm(actionResponse: .init(from: from, to: to, exchangeId: exchangeId))
                    
                case .creationError(let message):
                    error = GeneralError(errorMessage: message)
                    
                case .insufficientGas:
                    error = ExchangeErrors.networkFee
                    
                case .publishFailure(let code, let message):
                    error = GeneralError(errorMessage: "Error \(code): \(message)")
                }
                
                guard let error = error else { return }
                self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.failed(error: error)))
            }
            
        case .failed:
            error = GeneralError(errorMessage: "Unknown error")
            
        case .invalidAddress:
            error = GeneralError(errorMessage: "Invalid address")
            
        case .ownAddress:
            error = GeneralError(errorMessage: "Own address")
            
        case .insufficientFunds:
            error = ExchangeErrors.balanceTooLow(balance: dataStore.fromFeeAmount?.tokenValue ?? dataStore.quote?.fromFee?.fee ?? 0, currency: currency.code)
            
        case .noExchangeRate:
            error = ExchangeErrors.noQuote(from: dataStore.fromAmount?.currency.code, to: Constant.usdCurrencyCode)
            
        case .noFees:
            error = ExchangeErrors.noFees
            
        case .outputTooSmall(let amount):
            error = ExchangeErrors.tooLow(amount: amount.tokenValue, currency: Constant.usdCurrencyCode, reason: .swap)
            
        case .invalidRequest(let string):
            error = GeneralError(errorMessage: string)
            
        case .paymentTooSmall(let amount):
            error = ExchangeErrors.tooLow(amount: amount.tokenValue, currency: Constant.usdCurrencyCode, reason: .swap)
            
        case .usedAddress:
            error = GeneralError(errorMessage: "Used address")
            
        case .identityNotCertified(let string):
            error = GeneralError(errorMessage: "Not certified \(string)")
            
        case .insufficientGas:
            error = ExchangeErrors.networkFee
        }
        
        guard let error = error else { return }
        presenter?.presentError(actionResponse: .init(error: error))
    }
}
