//
//  OrderPreviewInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.8.22.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class OrderPreviewInteractor: NSObject, Interactor, OrderPreviewViewActions {
    typealias Models = OrderPreviewModels

    var presenter: OrderPreviewPresenter?
    var dataStore: OrderPreviewStore?
    
    private var biometricStatusRetryCounter: Int = 0
    
    // MARK: - OrderPreviewViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard dataStore?.type != nil else { return }
        guard let reference = dataStore?.paymentReference else {
            let item: Models.Item = (type: dataStore?.type,
                                     to: dataStore?.to,
                                     from: dataStore?.from,
                                     quote: dataStore?.quote,
                                     networkFee: dataStore?.networkFee,
                                     card: dataStore?.card,
                                     isAchAccount: dataStore?.isAchAccount)
            presenter?.presentData(actionResponse: .init(item: item))
            return
        }
        
        let requestData = PaymentStatusRequestData(reference: reference)
        PaymentStatusWorker().execute(requestData: requestData) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.paymentstatus = data?.status
                guard data?.status.isSuccesful == true || data?.status.achPending == true else {
                    self?.presenter?.presentSubmit(actionResponse: .init(paymentReference: self?.dataStore?.paymentReference,
                                                                         previewType: self?.dataStore?.type,
                                                                         isAch: self?.dataStore?.isAchAccount,
                                                                         failed: true,
                                                                         responseCode: data?.responseCode))
                    return
                }
                self?.presenter?.presentSubmit(actionResponse: .init(paymentReference: self?.dataStore?.paymentReference,
                                                                     previewType: self?.dataStore?.type,
                                                                     isAch: self?.dataStore?.isAchAccount,
                                                                     failed: false,
                                                                     responseCode: nil))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func showInfoPopup(viewAction: OrderPreviewModels.InfoPopup.ViewAction) {
        presenter?.presentInfoPopup(actionResponse: .init(isCardFee: viewAction.isCardFee, fee: dataStore?.quote?.buyFee))
    }
    
    func showCvvInfoPopup(viewAction: OrderPreviewModels.CvvInfoPopup.ViewAction) {
        presenter?.presentCvvInfoPopup(actionResponse: .init())
    }
    
    func submit(viewAction: OrderPreviewModels.Submit.ViewAction) {
        switch dataStore?.isAchAccount {
        case true:
            submitAchBuy()
        default:
            submitBuy()
        }
    }
    
    func checkTimeOut(viewAction: OrderPreviewModels.ExpirationValidations.ViewAction) {
        let isTimedOut = Date().timeIntervalSince1970 > (dataStore?.quote?.timestamp ?? 0) / 1000
        
        presenter?.presentTimeOut(actionResponse: .init(isTimedOut: isTimedOut))
    }
    
    func updateCvv(viewAction: OrderPreviewModels.CvvValidation.ViewAction) {
        dataStore?.cvv = viewAction.cvv
        let isValid = FieldValidator.validate(cvv: dataStore?.cvv)
        
        presenter?.presentCvv(actionResponse: .init(isValid: isValid))
    }
    
    func showTermsAndConditions(viewAction: OrderPreviewModels.TermsAndConditions.ViewAction) {
        guard let url = URL(string: C.termsAndConditions) else { return }
        presenter?.presentTermsAndConditions(actionResponse: .init(url: url))
    }
    
    func toggleTickbox(viewAction: OrderPreviewModels.Tickbox.ViewAction) {
        presenter?.presentToggleTickbox(actionResponse: .init(value: viewAction.value))
    }
    
    // MARK: - Aditional helpers
    
    private func submitBuy() {
        guard let currency = dataStore?.to?.currency,
              let address = currency.wallet?.defaultReceiveAddress,
              let to = dataStore?.to?.tokenValue,
              let from = dataStore?.from
        else { return }
        
        let cryptoFormatter = ExchangeFormatter.crypto
        cryptoFormatter.locale = Locale(identifier: C.usLocaleCode)
        cryptoFormatter.usesGroupingSeparator = false
        
        let toTokenValue = cryptoFormatter.string(for: to) ?? ""
        
        let fiatFormatter = ExchangeFormatter.fiat
        fiatFormatter.locale = Locale(identifier: C.usLocaleCode)
        fiatFormatter.usesGroupingSeparator = false
        
        let depositQuantity = from + (dataStore?.networkFee?.fiatValue ?? 0) + from * (dataStore?.quote?.buyFee ?? 1) / 100
        let formattedDepositQuantity = fiatFormatter.string(from: depositQuantity as NSNumber) ?? ""
        
        let data = SwapRequestData(quoteId: dataStore?.quote?.quoteId,
                                   depositQuantity: formattedDepositQuantity,
                                   withdrawalQuantity: toTokenValue,
                                   destination: address,
                                   sourceInstrumentId: dataStore?.card?.id,
                                   nologCvv: dataStore?.cvv?.description)
        
        SwapWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let exchangeData):
                self?.dataStore?.paymentReference = exchangeData?.paymentReference
                guard let redirectUrlString = exchangeData?.redirectUrl, let
                        redirectUrl = URL(string: redirectUrlString) else {
                    self?.getData(viewAction: .init())
                    return
                }
                
                ExchangeManager.shared.reload()
                self?.presenter?.presentThreeDSecure(actionResponse: .init(url: redirectUrl))
                
            case .failure(let error):
                guard let store = self?.dataStore,
                      let quoteId = store.quote?.quoteId,
                      (error as? NetworkingError)?.errorType == .biometricAuthentication else {
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                    return
                }
                
                self?.presenter?.presentVeriffLivenessCheck(actionResponse: .init(quoteId: String(quoteId), isBiometric: true))
            }
        }
    }
    
    func checkBiometricStatus(viewAction: OrderPreviewModels.BiometricStatusCheck.ViewAction) {
        guard let quoteId = dataStore?.quote?.quoteId else { return }
        
        if viewAction.resetCounter {
            biometricStatusRetryCounter = 5
        }
        biometricStatusRetryCounter -= 1
        
        BiometricStatusWorker().execute(requestData: BiometricStatusRequestData(quoteId: String(quoteId))) { [weak self] result in
            switch result {
            case .success(let data):
                guard let self = self, let status = data?.status else { return }
                
                switch status {
                case .approved:
                    self.submitBuy()
                    
                case .declined:
                    self.presenter?.presentSubmit(actionResponse: .init(paymentReference: nil, failed: true))
                    
                case .submitted, .started: // Case .started might not be needed in the future.
                    guard self.biometricStatusRetryCounter >= 0 else {
                        self.presenter?.presentError(actionResponse: .init(error: GeneralError()))
                        return
                    }
                    
                    self.checkBiometricStatus(viewAction: .init(resetCounter: false))
                    
                default:
                    self.presenter?.presentError(actionResponse: .init(error: GeneralError()))
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    private func submitAchBuy() {
        guard let currency = dataStore?.to?.currency,
              let address = currency.wallet?.defaultReceiveAddress,
              let to = dataStore?.to?.tokenValue,
              let from = dataStore?.from
        else { return }
        
        let cryptoFormatter = ExchangeFormatter.crypto
        cryptoFormatter.locale = Locale(identifier: C.usLocaleCode)
        cryptoFormatter.usesGroupingSeparator = false
        
        let toTokenValue = cryptoFormatter.string(for: to) ?? ""
        
        let fiatFormatter = ExchangeFormatter.fiat
        fiatFormatter.locale = Locale(identifier: C.usLocaleCode)
        fiatFormatter.usesGroupingSeparator = false
        
        let fromAmount = from * (1 + (dataStore?.quote?.buyFee ?? 0) / 100)
        let networkFee = dataStore?.networkFee?.fiatValue ?? 0
        let achFee = dataStore?.quote?.buyFeeUsd ?? 0
        
        let depositQuantity = fromAmount + networkFee + achFee
        let formattedDepositQuantity = fiatFormatter.string(from: depositQuantity as NSNumber) ?? ""
        
        let data = AchRequestData(quoteId: dataStore?.quote?.quoteId,
                                  depositQuantity: formattedDepositQuantity,
                                  withdrawalQuantity: toTokenValue,
                                  destination: address,
                                  accountId: dataStore?.card?.id,
                                  nologCvv: dataStore?.cvv?.description)
        
        AchWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let exchangeData):
                self?.dataStore?.paymentReference = exchangeData?.paymentReference
                guard let redirectUrlString = exchangeData?.redirectUrl, let
                        redirectUrl = URL(string: redirectUrlString) else {
                    self?.getData(viewAction: .init())
                    return
                }
                
                ExchangeManager.shared.reload()
                self?.presenter?.presentThreeDSecure(actionResponse: .init(url: redirectUrl))
                
            case .failure(let error):
                guard let store = self?.dataStore,
                      let quoteId = store.quote?.quoteId,
                      (error as? NetworkingError)?.errorType == .biometricAuthentication else {
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                    return
                }
                
                self?.presenter?.presentVeriffLivenessCheck(actionResponse: .init(quoteId: String(quoteId), isBiometric: true))
            }
        }
    }
}
