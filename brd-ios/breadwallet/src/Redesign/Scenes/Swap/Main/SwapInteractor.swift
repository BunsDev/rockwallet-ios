//
//  SwapInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

class SwapInteractor: NSObject, Interactor, SwapViewActions {
    
    typealias Models = SwapModels
    
    var presenter: SwapPresenter?
    var dataStore: SwapStore?
    
    private var sender: Sender?
    
    // MARK: - SwapViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard dataStore?.currencies.isEmpty == false else { return }
        
        let currencies = SupportedCurrenciesManager.shared.supportedCurrencies
        
        guard currencies.count >= 2 else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.selectAssets))
            return
        }
        
        dataStore?.supportedCurrencies = currencies
        dataStore?.currencies = dataStore?.currencies.filter { cur in currencies.map { $0.code }.contains(cur.code) } ?? []
        
        let fromCurrency: Currency? = dataStore?.from != nil ? dataStore?.from?.currency : dataStore?.currencies.first
        
        guard let fromCurrency,
              let toCurrency = dataStore?.currencies.first(where: { $0.code != fromCurrency.code })
        else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.selectAssets))
            return
        }
        if dataStore?.from == nil {
            dataStore?.from = .zero(fromCurrency)
        }
        dataStore?.to = .zero(toCurrency)
        
        presenter?.presentData(actionResponse: .init(item: Models.Item(from: dataStore?.from,
                                                                       to: dataStore?.to)))
        setInitialData(getFees: true)
    }
    
    func getCoingeckoExchangeRate(viewAction: ExchangeRateModels.CoingeckoRate.ViewAction, completion: (() -> Void)?) {
        guard let baseCurrency = dataStore?.from?.currency.coinGeckoId,
              let termCurrency = dataStore?.to?.currency.coinGeckoId else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noQuote(from: dataStore?.fromCode, to: dataStore?.toCode)))
            return
        }
        
        let coinGeckoIds = [baseCurrency, termCurrency]
        let vsCurrency = Constant.usdCurrencyCode.lowercased()
        let resource = Resources.simplePrice(ids: coinGeckoIds,
                                             vsCurrency: vsCurrency,
                                             options: [.change]) { [weak self] (result: Result<[SimplePrice], CoinGeckoError>) in
            switch result {
            case .success(let data):
                self?.dataStore?.fromRate = Decimal(data.first(where: { $0.id == baseCurrency })?.price ?? 0)
                self?.dataStore?.toRate = Decimal(data.first(where: { $0.id == termCurrency })?.price ?? 0)
                
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
    
    func switchPlaces(viewAction: SwapModels.SwitchPlaces.ViewAction) {
        guard let from = dataStore?.from?.currency,
              let to = dataStore?.to?.currency else { return }
        
        dataStore?.from = .zero(to)
        dataStore?.to = .zero(from)
        
        setInitialData(getFees: true)
    }
    
    private func setInitialData(getFees: Bool) {
        dataStore?.values = .init()
        dataStore?.quote = nil
        dataStore?.fromRate = nil
        dataStore?.toRate = nil
        dataStore?.fromFeeBasis = nil
        
        presenter?.presentError(actionResponse: .init(error: nil))
        
        getExchangeRate(viewAction: .init(getFees: false), completion: { [weak self] in
            self?.setPresentAmountData(handleErrors: false)
        })
    }
    
    func setAmount(viewAction: SwapModels.Amounts.ViewAction) {
        guard let fromRate = dataStore?.fromRate, let toRate = dataStore?.toRate, fromRate > 0, toRate > 0 else {
            return
        }
        
        guard let fromCurrency = dataStore?.from?.currency,
              let toCurrency = dataStore?.to?.currency else {
            presenter?.presentError(actionResponse: .init(error: GeneralError(errorMessage: L10n.ErrorMessages.noCurrencies)))
            return
        }
        
        let exchangeRate = dataStore?.quote?.exchangeRate ?? 1
        
        let toFeeRate = dataStore?.quote?.toFee?.feeRate ?? 1
        let toFee = (dataStore?.quote?.toFee?.fee ?? 0)
        
        let from: Amount
        let to: Amount
        
        if let fromCryptoAmount = viewAction.fromCryptoAmount,
           let fromCrypto = ExchangeFormatter.current.number(from: fromCryptoAmount)?.decimalValue {
            from = .init(decimalAmount: fromCrypto, isFiat: false, currency: fromCurrency, exchangeRate: fromRate)
            to = .init(decimalAmount: (fromCrypto - toFee / toFeeRate) * exchangeRate, isFiat: false, currency: toCurrency, exchangeRate: toRate)
            
        } else if let fromFiatAmount = viewAction.fromFiatAmount,
                  let fromFiat = ExchangeFormatter.current.number(from: fromFiatAmount)?.decimalValue {
            from = .init(decimalAmount: fromFiat, isFiat: true, currency: fromCurrency, exchangeRate: fromRate)
            to = .init(decimalAmount: (from.tokenValue - toFee / toFeeRate) * exchangeRate, isFiat: false, currency: toCurrency, exchangeRate: toRate)
            
        } else if let toCryptoAmount = viewAction.toCryptoAmount,
                  let toCrypto = ExchangeFormatter.current.number(from: toCryptoAmount)?.decimalValue {
            from = .init(decimalAmount: toCrypto / exchangeRate + toFee / toFeeRate, isFiat: false, currency: fromCurrency, exchangeRate: fromRate)
            to = .init(decimalAmount: toCrypto, isFiat: false, currency: toCurrency, exchangeRate: toRate)
            
        } else if let toFiatAmount = viewAction.toFiatAmount,
                  let toFiat = ExchangeFormatter.current.number(from: toFiatAmount)?.decimalValue {
            to = .init(decimalAmount: toFiat, isFiat: true, currency: toCurrency, exchangeRate: toRate)
            from = .init(decimalAmount: to.tokenValue / exchangeRate + toFee / toFeeRate, isFiat: false, currency: fromCurrency, exchangeRate: fromRate)
            
        } else {
            setPresentAmountData(handleErrors: viewAction.handleErrors)
            
            return
        }
        
        dataStore?.values = viewAction
        dataStore?.values.handleErrors = false
        dataStore?.from = from
        dataStore?.to = to
        
        setPresentAmountData(handleErrors: viewAction.handleErrors)
    }
    
    private func setPresentAmountData(handleErrors: Bool) {
        let isNotZero = !(dataStore?.from?.tokenValue ?? 0).isZero || !(dataStore?.to?.tokenValue ?? 0).isZero
        
        presenter?.presentAmount(actionResponse: .init(from: dataStore?.from,
                                                       to: dataStore?.to,
                                                       fromFee: dataStore?.fromFeeAmount,
                                                       toFee: dataStore?.toFeeAmount,
                                                       senderValidationResult: dataStore?.senderValidationResult,
                                                       fromFeeAmount: dataStore?.fromFeeAmount,
                                                       quote: dataStore?.quote,
                                                       baseBalance: dataStore?.from?.currency.state?.balance,
                                                       minimumValue: dataStore?.quote?.minimumValue,
                                                       minimumUsd: dataStore?.quote?.minimumUsd,
                                                       handleErrors: handleErrors && isNotZero))
    }
    
    func getFees(viewAction: Models.Fee.ViewAction) {
        guard let from = dataStore?.from,
              let fromAddress = from.currency.wallet?.defaultReceiveAddress,
              let sender else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noFees))
            
            return
        }
        
        fetchWalletKitFee(for: from,
                          with: sender,
                          address: fromAddress) { [weak self] fee in
            self?.dataStore?.fromFeeBasis = fee
            
            self?.dataStore?.senderValidationResult = sender.validate(amount: from, feeBasis: self?.dataStore?.fromFeeBasis)
            switch self?.dataStore?.senderValidationResult {
            case .ok:
                guard self?.dataStore?.fromFeeBasis != nil, self?.dataStore?.quote != nil else { return }
                
                self?.setPresentAmountData(handleErrors: true)
                
            default:
                self?.setPresentAmountData(handleErrors: true)
            }
        }
    }
    
    func assetSelected(viewAction: SwapModels.SelectedAsset.ViewAction) {
        guard let from = dataStore?.from?.currency,
              let to = dataStore?.to?.currency else { return }
        
        if let asset = viewAction.from,
           let from = dataStore?.currencies.first(where: { $0.code == asset }) {
            dataStore?.from = .zero(from)
            dataStore?.to = .zero(to)
        }
        
        if let asset = viewAction.to,
           let to = dataStore?.currencies.first(where: { $0.code == asset }) {
            dataStore?.to = .zero(to)
            dataStore?.from = .zero(from)
        }
        
        setInitialData(getFees: true)
    }
    
    func selectAsset(viewAction: SwapModels.Assets.ViewAction) {
        var from: [Currency]?
        var to: [Currency]?
        
        if viewAction.to == true {
            to = dataStore?.currencies.filter { $0.code != dataStore?.from?.currency.code }
        } else {
            from = dataStore?.currencies.filter { $0.code != dataStore?.to?.currency.code }
        }
        
        presenter?.presentSelectAsset(actionResponse: .init(from: from, to: to))
    }
    
    func showConfirmation(viewAction: SwapModels.ShowConfirmDialog.ViewAction) {
        presenter?.presentConfirmation(actionResponse: .init(from: dataStore?.from,
                                                             to: dataStore?.to,
                                                             quote: dataStore?.quote,
                                                             fromFee: dataStore?.fromFeeAmount,
                                                             toFee: dataStore?.toFeeAmount))
    }
    
    func confirm(viewAction: SwapModels.Confirm.ViewAction) {
        guard let currency = dataStore?.currencies.first(where: { $0.code == dataStore?.to?.currency.code }),
              let address = dataStore?.coreSystem?.wallet(for: currency)?.receiveAddress,
              let from = dataStore?.from?.tokenValue,
              let to = dataStore?.to?.tokenValue else { return }
        
        let formatter = ExchangeFormatter.crypto
        formatter.locale = Locale(identifier: Constant.usLocaleCode)
        formatter.usesGroupingSeparator = false
        
        let fromTokenValue = formatter.string(for: from) ?? ""
        let toTokenValue = formatter.string(for: to) ?? ""
        
        let data = SwapRequestData(quoteId: dataStore?.quote?.quoteId,
                                   depositQuantity: fromTokenValue,
                                   withdrawalQuantity: toTokenValue,
                                   destination: address)
        
        SwapWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.swap = data
                self?.createTransaction(from: data)
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.failed(error: error)))
            }
        }
    }
    
    func showAssetInfoPopup(viewAction: SwapModels.AssetInfoPopup.ViewAction) {
        presenter?.presentAssetInfoPopup(actionResponse: .init())
    }
    
    func showAssetSelectionMessage(viewAction: SwapModels.AssetSelectionMessage.ViewAction) {
        presenter?.presentAssetSelectionMessage(actionResponse: .init(from: dataStore?.from?.currency,
                                                                      to: dataStore?.to?.currency,
                                                                      selectedDisabledAsset: viewAction.selectedDisabledAsset))
    }
    
    // MARK: - Aditional helpers
    
    private func generateSender() -> Sender? {
        guard let fromCurrency = dataStore?.from?.currency,
              let wallet = dataStore?.coreSystem?.wallet(for: fromCurrency),
              let keyStore = dataStore?.keyStore,
              let kvStore = Backend.kvStore else { return nil }
        
        sender = Sender(wallet: wallet, authenticator: keyStore, kvStore: kvStore)
        
        sender?.updateNetworkFees()
        
        return sender
    }
    
    private func createTransaction(from swap: Swap?) {
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
            error = ExchangeErrors.noQuote(from: dataStore.from?.currency.code, to: dataStore.to?.currency.code)
            
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
