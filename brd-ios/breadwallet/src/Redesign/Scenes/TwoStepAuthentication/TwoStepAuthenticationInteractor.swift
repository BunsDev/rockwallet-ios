//
//  TwoStepAuthenticationInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 27/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class TwoStepAuthenticationInteractor: NSObject, Interactor, TwoStepAuthenticationViewActions {
    typealias Models = TwoStepAuthenticationModels
    
    var presenter: TwoStepAuthenticationPresenter?
    var dataStore: TwoStepAuthenticationStore?
    
    // MARK: - TwoStepAuthenticationViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: nil))
    }
    
    // MARK: - Aditional helpers
}
