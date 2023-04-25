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
        presenter?.presentData(actionResponse: .init(item: dataStore?.screenType))
    }
    
    func showPaymailPopup(viewAction: Models.InfoPopup.ViewAction) {
        presenter?.presentPaymailPopup(actionResponse: .init())
    }

    func showSuccessBottomAlert(viewAction: Models.Success.ViewAction) {
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
    
    // MARK: - Aditional helpers
}
