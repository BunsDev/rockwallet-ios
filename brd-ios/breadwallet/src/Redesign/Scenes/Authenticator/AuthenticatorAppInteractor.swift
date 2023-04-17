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

    // MARK: - AuthenticatorAppViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: nil))
        
        TwoStepChangeWorker().execute(requestData: TwoStepChangeRequestData()) { _ in }
    }
    
    func copyValue(viewAction: AuthenticatorAppModels.CopyValue.ViewAction) {
        let value = viewAction.value?.filter { !$0.isWhitespace } ?? ""
        UIPasteboard.general.string = value
        
        presenter?.presentCopyValue(actionResponse: .init())
    }
    
    func next(viewAction: AuthenticatorAppModels.Next.ViewAction) {
        presenter?.presentNext(actionResponse: .init())
    }
    
    // MARK: - Aditional helpers
}
