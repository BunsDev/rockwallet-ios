//
//  Sender.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-01-16.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import Foundation
import UIKit
import WalletKit

enum SendResult {
    case success(hash: String?, rawTx: String?)
    case creationError(message: String)
    case publishFailure(code: Int, message: String)
    case insufficientGas(message: String)
}

enum SenderValidationResult {
    case ok
    case failed
    case invalidAddress
    case ownAddress
    case insufficientFunds
    case noExchangeRate
    
    // BTC errors
    case noFees // fees not downlaoded
    case outputTooSmall(Amount)
    
    // protocol request errors
    case invalidRequest(String)
    case paymentTooSmall(Amount)
    case usedAddress
    case identityNotCertified(String)
    
    // token errors
    case insufficientGas // no eth for token transfer gas
}

typealias PinVerifier = (@escaping (String) -> Void) -> Void
typealias SendCompletion = (SendResult) -> Void

class Sender: Subscriber {
    
    let wallet: Wallet
    private let kvStore: BRReplicatedKVStore
    private let authenticator: TransactionAuthenticator
    
    private var comment: String?
    private var gift: Gift?
    private var transfer: WalletKit.Transfer?
    private var protocolRequest: PaymentProtocolRequest?
    var maximum: Amount?
    var minimum: Amount?
    
    var displayPaymentProtocolResponse: ((String) -> Void)?
    
    private var submitTimeoutTimer: Timer? {
        willSet {
            submitTimeoutTimer?.invalidate()
        }
    }
    private let submitTimeout: TimeInterval = 20.0 // 60.0 is original setting

    private var isOriginatingTransferNeeded: Bool {
        return wallet.currency.tokenType == .erc20
    }

    var canUseBiometrics: Bool {
        return authenticator.isBiometricsEnabledForTransactions
    }

    // MARK: Init

    init(wallet: Wallet, authenticator: TransactionAuthenticator, kvStore: BRReplicatedKVStore) {
        self.wallet = wallet
        self.authenticator = authenticator
        self.kvStore = kvStore
    }

    func reset() {
        transfer = nil
        comment = nil
        protocolRequest = nil
    }
    
    func updateNetworkFees() {
        wallet.updateNetworkFees()
    }

    // MARK: Create

    func estimateFee(address: String, amount: Amount, tier: FeeLevel, isStake: Bool, completion: @escaping (Result<TransferFeeBasis, Error>) -> Void) {
        wallet.estimateFee(address: address, amount: amount, fee: tier, isStake: isStake) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    public func estimateLimitMaximum (address: String,
                                      fee: FeeLevel,
                                      completion: @escaping WalletKit.Wallet.EstimateLimitHandler) {
        wallet.estimateLimitMaximum(address: address, fee: fee, completion: completion)
    }
    
    public func estimateLimitMinimum (address: String,
                                      fee: FeeLevel,
                                      completion: @escaping WalletKit.Wallet.EstimateLimitHandler) {
        wallet.estimateLimitMinimum(address: address, fee: fee, completion: completion)
    }

    private func validate(address: String, amount: Amount, feeBasis: TransferFeeBasis? = nil) -> SenderValidationResult {
        guard wallet.currency.isValidAddress(address) else { return .invalidAddress }
        guard !wallet.isOwnAddress(address) else { return .ownAddress }

        return validate(amount: amount, feeBasis: feeBasis)
    }
    
    func validate(amount: Amount, feeBasis: TransferFeeBasis? = nil) -> SenderValidationResult {
        if let minOutput = minimum {
            guard amount >= minOutput else { return .outputTooSmall(minOutput) }
        }

        if let maximum = maximum {
            guard amount <= maximum else { return .insufficientFunds }
        } else if let balance = wallet.currency.state?.balance {
            guard amount <= balance else { return .insufficientFunds }
        }
        if wallet.feeCurrency != wallet.currency {
            if let feeBalance = wallet.feeCurrency.state?.balance, let feeBasis = feeBasis {
                let feeAmount = Amount(cryptoAmount: feeBasis.fee, currency: wallet.feeCurrency)
                if feeBalance.tokenValue < feeAmount.tokenValue {
                    return .insufficientGas
                }
            }
        }
        return .ok
    }
    
    func createTransaction(outputScript: String? = nil,
                           address: String,
                           amount: Amount,
                           feeBasis: TransferFeeBasis,
                           comment: String? = nil,
                           attribute: String? = nil,
                           gift: Gift? = nil,
                           exchangeId: String? = nil,
                           secondFactorCode: String? = nil,
                           secondFactorBackup: String? = nil) -> SenderValidationResult {
        let result = validate(address: address, amount: amount, feeBasis: feeBasis)
        guard case .ok = result else { return result }
        
        reset()
        
        switch wallet.createTransfer(outputScript: outputScript,
                                     to: address,
                                     amount: amount,
                                     feeBasis: feeBasis,
                                     attribute: attribute,
                                     exchangeId: exchangeId,
                                     secondFactorCode: secondFactorCode,
                                     secondFactorBackup: secondFactorBackup) {
        case .success(let transfer):
            self.comment = comment
            self.gift = gift
            transfer.exchangeId = exchangeId
            self.transfer = transfer
            return .ok
            
        case .failure(let error) where error == .invalidAddress:
            return .invalidAddress
            
        case .failure(let error):
            print(error.localizedDescription)
            return .insufficientGas
        }
    }

    // MARK: Create Payment Request
    private func validate(protocolRequest protoReq: PaymentProtocolRequest, ignoreUsedAddress: Bool, ignoreIdentityNotCertified: Bool) -> SenderValidationResult {
        if !protoReq.isSecure && !ignoreIdentityNotCertified {
            return .identityNotCertified("")
        }
        guard let address = protoReq.primaryTarget?.description else {
            return .invalidAddress
        }
        guard let amount = protoReq.totalAmount else {
            return .invalidRequest("No Amount Specified")
        }
        return validate(address: address, amount: Amount(cryptoAmount: amount, currency: wallet.currency), feeBasis: nil)
    }

    func createTransaction(protocolRequest protoReq: PaymentProtocolRequest,
                           ignoreUsedAddress: Bool,
                           ignoreIdentityNotCertified: Bool,
                           feeBasis: TransferFeeBasis,
                           comment: String?) -> SenderValidationResult {
        let result = validate(protocolRequest: protoReq, ignoreUsedAddress: ignoreUsedAddress, ignoreIdentityNotCertified: ignoreIdentityNotCertified)
        guard case .ok = result else { return result }
        
        reset()
        
        switch wallet.createTransfer(forProtocolRequest: protoReq, feeBasis: feeBasis) {
        case .success(let transfer):
            self.comment = comment
            self.transfer = transfer
            self.protocolRequest = protoReq
            return .ok
        case .failure(let error) where error == .invalidAddress:
            return .invalidAddress
        default:
            return .failed
        }
    }

    // MARK: Submit

    func sendTransaction(allowBiometrics: Bool, exchangeId: String? = nil, pinVerifier: @escaping PinVerifier, completion: @escaping SendCompletion) {
        guard let transfer = transfer else { return completion(.creationError(message: "no tx")) }
        transfer.exchangeId = exchangeId
        if allowBiometrics && canUseBiometrics {
            sendWithBiometricVerification(transfer: transfer, completion: completion)
        } else {
            sendWithPinVerification(transfer: transfer, pinVerifier: pinVerifier, completion: completion)
        }
    }
    
    func stake(address: String, pinVerifier: @escaping PinVerifier, completion: @escaping SendCompletion) {
        wallet.estimateFee(address: address,
                           amount: Amount.zero(wallet.currency),
                           fee: .regular,
                           isStake: true,
                           completion: { result in
            switch result {
            case .success(let fee):
                let result = self.wallet.currency.wallet?.stake(address: address, feeBasis: fee)
                guard case .success(let transfer) = result else {
                    return completion(.creationError(message: "no tx")) }
                pinVerifier { pin in
                    guard self.authenticator.signAndSubmit(transfer: transfer, wallet: self.wallet, withPin: pin) else {
                        return completion(.creationError(message: L10n.Send.Error.authenticationError))
                    }
                    self.waitForSubmission(of: transfer, completion: completion)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    private func sendWithPinVerification(transfer: Transfer,
                                         pinVerifier: PinVerifier,
                                         completion: @escaping SendCompletion) {
        // this block requires a strong reference to self to ensure the Sender is not deallocated before completion
        pinVerifier { pin in
            guard self.authenticator.signAndSubmit(transfer: transfer, wallet: self.wallet, withPin: pin) else {
                return completion(.creationError(message: L10n.Send.Error.authenticationError))
            }
            self.waitForSubmission(of: transfer, completion: completion)
        }
    }
    
    private func sendWithBiometricVerification(transfer: Transfer, completion: @escaping SendCompletion) {
        let biometricsPrompt = L10n.VerifyPin.touchIdMessage
        self.authenticator.signAndSubmit(transfer: transfer,
                                         wallet: self.wallet,
                                         withBiometricsPrompt: biometricsPrompt) { result in
            switch result {
            case .success:
                self.waitForSubmission(of: transfer, completion: completion)
            case .failure, .fallback:
                completion(.creationError(message: L10n.Send.Error.authenticationError))
            default:
                completion(.creationError(message: "Something went wrong"))
            }
        }
    }

    private func waitForSubmission(of transfer: Transfer, completion: @escaping SendCompletion) {
        GoogleAnalytics.logEvent(GoogleAnalytics.Transaction(currencyId: String(describing: transfer.wallet.currency.uid), txHash: transfer.hash?.description ?? ""))
        
        let handleSuccess: (_ originatingTx: Transfer?) -> Void = { originatingTx in
            DispatchQueue.main.async {
                self.stopWaitingForSubmission()
                self.setMetaData(originatingTransfer: originatingTx)
                if let protoReq = self.protocolRequest {
                    PaymentRequest.postProtocolPayment(protocolRequest: protoReq, transfer: transfer) {
                        self.displayPaymentProtocolResponse?($0)
                    }
                }
                //TODO:CRYPTO raw tx is only needed by platform, but currently unused
                completion(.success(hash: transfer.hash?.description, rawTx: nil))
            }
        }

        let handleFailure = {
            DispatchQueue.main.async {
                self.stopWaitingForSubmission()
                //TODO:CRYPTO propagate errors
                completion(.publishFailure(code: 0, message: ""))
            }
        }

        let handleTimeout = {
            DispatchQueue.main.async {
                self.stopWaitingForSubmission()
                completion(.publishFailure(code: 0, message: L10n.Send.timeOutBody))
            }
        }

        self.wallet.subscribe(self) { event in
            guard case .transferSubmitted(let eventTransfer, _) = event,
                  transfer == eventTransfer || (transfer.hash != nil && transfer.hash == eventTransfer.hash) else { return }
            switch eventTransfer.state {
            case .submitted,
                 .included,
                 .pending:
                // for token transfers wait for the transaction in the native wallet to be submitted
                guard !self.isOriginatingTransferNeeded else { return }
                handleSuccess(nil)
            case .failed,
                 .deleted:
                handleFailure()
            case .created,
                 .signed:
                return
            }
        }

        if isOriginatingTransferNeeded, let primaryWallet = wallet.networkPrimaryWallet {
            primaryWallet.subscribe(self) { event in
                guard case .transferSubmitted(let eventTransfer, let success) = event,
                    eventTransfer.hash == transfer.hash else { return }
                guard success else { return handleFailure() }
                handleSuccess(eventTransfer)
            }
        }

        DispatchQueue.main.async {
            self.submitTimeoutTimer = Timer.scheduledTimer(withTimeInterval: self.submitTimeout, repeats: false) { _ in
                handleTimeout()
            }
        }
    }

    private func stopWaitingForSubmission() {
        self.wallet.unsubscribe(self)
        if isOriginatingTransferNeeded {
            wallet.networkPrimaryWallet?.unsubscribe(self)
        }
        self.submitTimeoutTimer = nil
    }

    private func setMetaData(originatingTransfer: Transfer? = nil) {
        guard let transfer = transfer,
            let rate = wallet.currency.state?.currentRate else { print("[SEND] missing tx metadata")
            return
        }
        let tx = Transaction(transfer: transfer,
                             wallet: wallet,
                             kvStore: kvStore,
                             rate: rate)
        let feeRate = tx.feeBasis?.pricePerCostFactor.tokenValue.doubleValue

        let newGift: Gift? = gift != nil ? Gift(shared: false,
                                                claimed: false,
                                                reclaimed: false,
                                                txnHash: transfer.hash?.description,
                                                keyData: gift!.keyData,
                                                name: gift!.name,
                                                rate: gift!.rate,
                                                amount: gift!.amount) : nil
        tx.createMetaData(rate: rate,
                          comment: comment,
                          feeRate: feeRate,
                          tokenTransfer: nil,
                          gift: newGift,
                          kvStore: kvStore)

        // for non-native token transfers, the originating transaction on the network's primary wallet captures the fee spent
        if let originatingTransfer = originatingTransfer,
            let originatingWallet = wallet.networkPrimaryWallet,
            let rate = originatingWallet.currency.state?.currentRate {
            assert(isOriginatingTransferNeeded && transfer.hash == originatingTransfer.hash)
            let originatingTx = Transaction(transfer: originatingTransfer,
                                            wallet: originatingWallet,
                                            kvStore: kvStore,
                                            rate: rate)
            originatingTx.createMetaData(rate: rate, tokenTransfer: wallet.currency.code, kvStore: kvStore)
        }
        
        if newGift != nil {
            //gifing needs a delay for some reason
            DispatchQueue.main.asyncAfter(deadline: .now() + Presets.Delay.long.rawValue) {
                print("[gifting] txMetaDataUpdated: \(tx.hash)")
                Store.trigger(name: .txMetaDataUpdated(tx.hash))
            }
        } else {
            DispatchQueue.main.async {
                Store.trigger(name: .txMetaDataUpdated(tx.hash))
            }
        }
    }
}
