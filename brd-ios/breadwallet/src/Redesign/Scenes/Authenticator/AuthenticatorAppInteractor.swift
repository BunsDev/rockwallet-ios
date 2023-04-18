//
//  AuthenticatorAppInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class AuthenticatorAppInteractor: NSObject, Interactor, AuthenticatorAppViewActions {
    typealias Models = AuthenticatorAppModels

    var presenter: AuthenticatorAppPresenter?
    var dataStore: AuthenticatorAppStore?
    
    private var setTwoStepAppModel: SetTwoStepApp?
    
    // MARK: - AuthenticatorAppViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        let data = SetTwoStepAppRequestData(updateCode: nil)
        SetTwoStepAppWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                self?.setTwoStepAppModel = data
                
                self?.presenter?.presentData(actionResponse: .init(item: self?.setTwoStepAppModel))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func copyValue(viewAction: AuthenticatorAppModels.CopyValue.ViewAction) {
        let value = viewAction.value?.filter { !$0.isWhitespace } ?? ""
        UIPasteboard.general.string = value
        
        presenter?.presentCopyValue(actionResponse: .init())
    }
    
    func openTotpUrl(viewAction: AuthenticatorAppModels.OpenTotpUrl.ViewAction) {
        presenter?.presentOpenTotpUrl(actionResponse: .init(url: setTwoStepAppModel?.url))
    }
    
    func next(viewAction: AuthenticatorAppModels.Next.ViewAction) {
        presenter?.presentNext(actionResponse: .init())
    }
    
    // MARK: - Aditional helpers
}
