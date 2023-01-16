//
//  SignInInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SignInInteractor: NSObject, Interactor, SignInViewActions {
    
    typealias Models = SignInModels
    
    var presenter: SignInPresenter?
    var dataStore: SignInStore?
    
    // MARK: - SignInViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item(email: "", password: "")))
    }
    
    func validate(viewAction: SignInModels.Validate.ViewAction) {
        if let email = viewAction.email {
            dataStore?.email = email
        }
        
        if let password = viewAction.password {
            dataStore?.password = password
        }
        
        let isValid = FieldValidator.validate(fields: [dataStore?.email,
                                                       dataStore?.password])
        
        presenter?.presentValidate(actionResponse: .init(isValid: isValid))
    }
    
    func next(viewAction: SignInModels.Next.ViewAction) {
        guard let email = dataStore?.email,
              let password = dataStore?.password,
              let token = UserDefaults.walletTokenValue else { return }
        
        let data = RegistrationRequestData(email: email,
                                           password: password,
                                           token: token,
                                           subscribe: nil,
                                           accountHandling: .login)
        RegistrationWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                guard let sessionKey = data?.sessionKey else { return }
                
                UserDefaults.email = email
                UserDefaults.kycSessionKeyValue = sessionKey
                
                UserManager.shared.refresh { _ in
                    self?.presenter?.presentNext(actionResponse: .init())
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    // MARK: - Aditional helpers
}
