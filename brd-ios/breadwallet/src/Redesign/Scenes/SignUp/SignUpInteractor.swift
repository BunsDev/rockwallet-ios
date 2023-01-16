//
//  SignUpInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SignUpInteractor: NSObject, Interactor, SignUpViewActions {
    
    typealias Models = SignUpModels
    
    var presenter: SignUpPresenter?
    var dataStore: SignUpStore?
    
    // MARK: - SignUpViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item(email: "", password: "", passwordAgain: "")))
    }
    
    func validate(viewAction: SignUpModels.Validate.ViewAction) {
        if let email = viewAction.email {
            dataStore?.email = email
        }
        
        if let password = viewAction.password {
            dataStore?.password = password
        }
        
        if let passwordAgain = viewAction.passwordAgain {
            dataStore?.passwordAgain = passwordAgain
        }
        
        let isEmailValid = FieldValidator.validate(fields: [dataStore?.email])
        let isPasswordValid = FieldValidator.validate(fields: [dataStore?.password,
                                                               dataStore?.passwordAgain]) && dataStore?.password == dataStore?.passwordAgain
        let isTermsTickboxValid = dataStore?.termsTickbox == true
        
        presenter?.presentValidate(actionResponse: .init(isEmailValid: isEmailValid,
                                                         isPasswordValid: isPasswordValid,
                                                         isTermsTickboxValid: isTermsTickboxValid))
    }
    
    func toggleTermsTickbox(viewAction: SignUpModels.TermsTickbox.ViewAction) {
        dataStore?.termsTickbox = viewAction.value
        
        validate(viewAction: .init())
    }
    
    func togglePromotionsTickbox(viewAction: SignUpModels.PromotionsTickbox.ViewAction) {
        dataStore?.promotionsTickbox = viewAction.value
    }
    
    // MARK: - Aditional helpers
}
