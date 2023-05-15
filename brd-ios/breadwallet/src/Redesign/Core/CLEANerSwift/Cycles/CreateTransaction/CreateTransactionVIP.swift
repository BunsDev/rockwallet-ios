// 
//  CreateTransactionVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 15/05/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

protocol CreateTransactionViewActions {
    func createTransaction(viewAction: CreateTransactionModels.Transaction.ViewAction?, completion: ((FEError?) -> Void)?)
    func generateSender(viewAction: CreateTransactionModels.Sender.ViewAction)
}

protocol CreateTransactionDataStore: NSObject {
    var sender: Sender? { get set }
}

extension Interactor where Self: CreateTransactionViewActions,
                           Self.DataStore: CreateTransactionDataStore {
    func createTransaction(viewAction: CreateTransactionModels.Transaction.ViewAction?, completion: ((FEError?) -> Void)?) {
        guard let viewAction,
              let sender = dataStore?.sender,
              let exchange = viewAction.exchange,
              let fromFeeBasis = viewAction.fromFeeBasis,
              let fromFeeAmount = viewAction.fromFeeAmount,
              let fromAmount = viewAction.fromAmount,
              let toAmount = viewAction.toAmount,
              let destination = viewAction.exchange?.address,
              let amountValue = viewAction.exchange?.amount,
              let exchangeId = viewAction.exchange?.exchangeId,
              let currency = viewAction.currencies?.first(where: { $0.code == exchange.currency }) else {
            completion?(ExchangeErrors.noFees)
            return
        }
        
        let amount = Amount(decimalAmount: amountValue, isFiat: false, currency: currency)
        let transaction = sender.createTransaction(address: destination,
                                                               amount: amount,
                                                               feeBasis: fromFeeBasis,
                                                               exchangeId: exchangeId)
        
        var error: FEError?
        switch transaction {
        case .ok:
            sender.sendTransaction(allowBiometrics: false, exchangeId: exchangeId) { data in
                guard let pin: String = try? keychainItem(key: KeychainKey.pin) else {
                    completion?(ExchangeErrors.pinConfirmation)
                    return
                }
                data(pin)
            } completion: { result in
                defer { sender.reset() }
                
                var error: FEError?
                
                switch result {
                case .success:
                    ExchangeManager.shared.reload()
                    
                    completion?(nil)
                    
                case .creationError(let message):
                    error = GeneralError(errorMessage: message)
                    
                case .insufficientGas:
                    error = ExchangeErrors.networkFee
                    
                case .publishFailure(let code, let message):
                    error = GeneralError(errorMessage: "\(L10n.Transaction.failed) \(code): \(message)")
                }
                
                completion?(error)
            }
            
        case .failed:
            error = GeneralError(errorMessage: L10n.ErrorMessages.unknownError)
            
        case .invalidAddress:
            error = GeneralError(errorMessage: L10n.UDomains.invalid)
            
        case .ownAddress:
            error = GeneralError(errorMessage: L10n.Send.containsAddress)
            
        case .insufficientFunds:
            error = ExchangeErrors.balanceTooLow(balance: fromFeeAmount.tokenValue,
                                                 currency: currency.code)
            
        case .noExchangeRate:
            error = ExchangeErrors.noQuote(from: fromAmount.currency.code,
                                           to: Constant.usdCurrencyCode)
            
        case .noFees:
            error = ExchangeErrors.noFees
            
        case .outputTooSmall(let amount):
            error = ExchangeErrors.tooLow(amount: amount.tokenValue,
                                          currency: Constant.usdCurrencyCode,
                                          reason: .swap)
            
        case .invalidRequest(let string):
            error = GeneralError(errorMessage: string)
            
        case .paymentTooSmall(let amount):
            error = ExchangeErrors.tooLow(amount: amount.tokenValue,
                                          currency: Constant.usdCurrencyCode,
                                          reason: .swap)
            
        case .usedAddress:
            error = GeneralError(errorMessage: "Used address")
            
        case .identityNotCertified(let string):
            error = GeneralError(errorMessage: "Not certified \(string)")
            
        case .insufficientGas:
            error = ExchangeErrors.networkFee
            
        }
        
        completion?(error)
    }
    
    func generateSender(viewAction: CreateTransactionModels.Sender.ViewAction) {
        guard let fromCurrency = viewAction.fromAmount?.currency,
              let wallet = viewAction.coreSystem?.wallet(for: fromCurrency),
              let keyStore = viewAction.keyStore,
              let kvStore = Backend.kvStore else { return }
        
        let sender = Sender(wallet: wallet, authenticator: keyStore, kvStore: kvStore)
        sender.updateNetworkFees()
        
        dataStore?.sender = sender
    }
}
