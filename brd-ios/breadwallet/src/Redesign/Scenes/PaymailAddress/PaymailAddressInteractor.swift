//
//  PaymailAddressInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.4.23.
//
//

import UIKit

class PaymailAddressInteractor: NSObject, Interactor, PaymailAddressViewActions {
    typealias Models = PaymailAddressModels

    var presenter: PaymailAddressPresenter?
    var dataStore: PaymailAddressStore?

    // MARK: - PaymailAddressViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: dataStore))
    }
    
    func showPaymailPopup(viewAction: Models.InfoPopup.ViewAction) {
        presenter?.presentPaymailPopup(actionResponse: .init())
    }

    func showSuccessBottomAlert(viewAction: Models.BottomAlert.ViewAction) {
        dataStore?.screenType = .paymailSetup
        presenter?.presentSuccessBottomAlert(actionResponse: .init())
    }
    
    func validate(viewAction: Models.Validate.ViewAction) {
        if let email = viewAction.email {
            dataStore?.paymailAddress = email
        }
        
        let isEmailValid = dataStore?.paymailAddress?.isValidEmailAddress ?? false
        let isEmailEmpty = dataStore?.paymailAddress?.isEmpty == true
        let emailState: DisplayState? = isEmailEmpty || isEmailValid ? nil : .error
        
        presenter?.presentValidate(actionResponse: .init(email: viewAction.email,
                                                         isEmailValid: isEmailValid,
                                                         isEmailEmpty: isEmailEmpty,
                                                         emailState: emailState))
    }
    
    func clearPaymail(viewAction: Models.ClearPaymail.ViewAction) {
        dataStore?.paymailAddress = viewAction.email
        let isEmailValid = false
        let isEmailEmpty = true
        let emailState: DisplayState? = isEmailEmpty || isEmailValid ? nil : .error
        
        presenter?.presentValidate(actionResponse: .init(email: dataStore?.paymailAddress,
                                                         isEmailValid: isEmailValid,
                                                         isEmailEmpty: isEmailEmpty,
                                                         emailState: emailState))
    }
    
    func createPaymailAddress(viewAction: Models.CreatePaymail.ViewAction) {
        guard let email = dataStore?.paymailAddress else { return }
        let paymailEmail = email.replacingOccurrences(of: Constant.paymailDomain, with: "")
        let data = PaymailRequestData(paymail: paymailEmail, xpub: getXPub(code: "bsv"))
        PaymailAddressWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentPaymailSuccess(actionResponse: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func getXPub(code: String) -> String {
        var keyStore: KeyStore
        do {
            keyStore = try KeyStore.create()
        } catch { 
            fatalError("error initializing key store")
        }
        let xpub = keyStore.getXPubFromAccount(code: code)
        return xpub
    }
    
    // MARK: - Aditional helpers
}
