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
        presenter?.presentData(actionResponse: .init(item: Models.Item(email: dataStore?.email,
                                                                       password: dataStore?.password,
                                                                       passwordAgain: dataStore?.passwordAgain)))
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
        
        let passwordRegex = "(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!?&@€)(/]).{8,}"
        
        let isEmailValid = dataStore?.email?.isValidEmailAddress ?? false
        let isPasswordValid = dataStore?.password?.matches(regularExpression: passwordRegex) ?? false
        && dataStore?.passwordAgain?.matches(regularExpression: passwordRegex) ?? false
        && dataStore?.password == dataStore?.passwordAgain
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
    
    func next(viewAction: SignUpModels.Next.ViewAction) {
        guard let email = dataStore?.email,
              let password = dataStore?.password,
              let token = UserDefaults.walletTokenValue else { return }
        
        let data = RegistrationRequestData(email: email,
                                           password: password,
                                           token: token,
                                           subscribe: dataStore?.promotionsTickbox ?? false,
                                           accountHandling: .register)
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
