//
//  AuthenticatorAppVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let AuthenticatorApp = AuthenticatorAppViewController.self
}

protocol AuthenticatorAppViewActions: BaseViewActions, FetchViewActions {
    func copyValue(viewAction: AuthenticatorAppModels.CopyValue.ViewAction)
    func next(viewAction: AuthenticatorAppModels.Next.ViewAction)
}

protocol AuthenticatorAppActionResponses: BaseActionResponses, FetchActionResponses {
    func presentCopyValue(actionResponse: AuthenticatorAppModels.CopyValue.ActionResponse)
    func presentNext(actionResponse: AuthenticatorAppModels.Next.ActionResponse)
}

protocol AuthenticatorAppResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayNext(responseDisplay: AuthenticatorAppModels.Next.ResponseDisplay)
}

protocol AuthenticatorAppDataStore: BaseDataStore, FetchDataStore {
}

protocol AuthenticatorAppDataPassing {
    var dataStore: (any AuthenticatorAppDataStore)? { get }
}

protocol AuthenticatorAppRoutes: CoordinatableRoutes {
}
