//
//  VerifyPhoneNumberInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class VerifyPhoneNumberInteractor: NSObject, Interactor, VerifyPhoneNumberViewActions {
    typealias Models = VerifyPhoneNumberModels
    
    var presenter: VerifyPhoneNumberPresenter?
    var dataStore: VerifyPhoneNumberStore?
    
    // MARK: - VerifyPhoneNumberViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: nil))
    }
    
    func setAreaCode(viewAction: VerifyPhoneNumberModels.SetAreaCode.ViewAction) {
        presenter?.presentSetAreaCode(actionResponse: .init(areaCode: viewAction.areaCode))
    }
    
    func validate(viewAction: VerifyPhoneNumberModels.Validate.ViewAction) {
        
    }
    
    func confirm(viewAction: VerifyPhoneNumberModels.Confirm.ViewAction) {
//        let data = VerifyPhoneNumberRequestData(code: dataStore?.code)
//        VerifyPhoneNumberWorker().execute(requestData: data) { [weak self] result in
//            switch result {
//            case .success:
//                UserManager.shared.refresh()
//
//                self?.presenter?.presentConfirm(actionResponse: .init())
//
//            case .failure(let error):
//                self?.presenter?.presentError(actionResponse: .init(error: error))
//            }
//        }
    }
    
    // MARK: - Aditional helpers
}
