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
    
    // MARK: - Aditional helpers
}
