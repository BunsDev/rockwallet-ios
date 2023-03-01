//
//  RegistrationConfirmationInteractor.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationConfirmationInteractor: NSObject, Interactor, RegistrationConfirmationViewActions {
    typealias Models = RegistrationConfirmationModels

    var presenter: RegistrationConfirmationPresenter?
    var dataStore: RegistrationConfirmationStore?

    // MARK: - RegistrationConfirmationViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: UserDefaults.email))
    }
    
    func validate(viewAction: RegistrationConfirmationModels.Validate.ViewAction) {
        let code = viewAction.item ?? ""
        
        dataStore?.code = code
        
        if code.count == CodeInputView.numberOfFields {
            confirm(viewAction: .init())
        }
        
        presenter?.presentValidate(actionResponse: .init(isValid: code.count == CodeInputView.numberOfFields))
    }
    
    func confirm(viewAction: RegistrationConfirmationModels.Confirm.ViewAction) {
        let data = RegistrationConfirmationRequestData(code: dataStore?.code)
        RegistrationConfirmationWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                UserManager.shared.refresh()
                
                self?.presenter?.presentConfirm(actionResponse: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func resend(viewAction: RegistrationConfirmationModels.Resend.ViewAction) {
        ResendConfirmationWorker().execute { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentResend(actionResponse: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }

    // MARK: - Aditional helpers
}
