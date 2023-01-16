//
//  ForgotPasswordInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class ForgotPasswordInteractor: NSObject, Interactor, ForgotPasswordViewActions {
    
    typealias Models = ForgotPasswordModels
    
    var presenter: ForgotPasswordPresenter?
    var dataStore: ForgotPasswordStore?
    
    // MARK: - ForgotPasswordViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item("")))
    }
    
    func validate(viewAction: ForgotPasswordModels.Validate.ViewAction) {
        if let email = viewAction.email {
            dataStore?.email = email
        }
        
        let isEmailValid = dataStore?.email?.isValidEmailAddress ?? false
        
        presenter?.presentValidate(actionResponse: .init(isValid: isEmailValid))
    }
    
    func next(viewAction: ForgotPasswordModels.Next.ViewAction) {
        PasswordResetWorker().execute(requestData: PasswordResetRequestData(email: dataStore?.email)) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentNext(actionResponse: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    // MARK: - Aditional helpers
}
