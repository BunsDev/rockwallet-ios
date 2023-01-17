//
//  SetPasswordInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SetPasswordInteractor: NSObject, Interactor, SetPasswordViewActions {
    
    typealias Models = SetPasswordModels
    
    var presenter: SetPasswordPresenter?
    var dataStore: SetPasswordStore?
    
    // MARK: - SetPasswordViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item(password: "", passwordAgain: "")))
    }
    
    func validate(viewAction: SetPasswordModels.Validate.ViewAction) {
        if let password = viewAction.password {
            dataStore?.password = password
        }
        
        if let passwordAgain = viewAction.passwordAgain {
            dataStore?.passwordAgain = passwordAgain
        }
        
        let isPasswordValid = dataStore?.password?.isValidPassword ?? false
        && dataStore?.passwordAgain?.isValidPassword ?? false
        && dataStore?.password == dataStore?.passwordAgain
        
        presenter?.presentValidate(actionResponse: .init(isValid: isPasswordValid))
    }
    
    // MARK: - Aditional helpers
}
