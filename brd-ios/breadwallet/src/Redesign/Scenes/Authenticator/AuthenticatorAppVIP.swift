//
//  EnterCodeView.swift
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
}

protocol AuthenticatorAppActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol AuthenticatorAppResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol AuthenticatorAppDataStore: BaseDataStore, FetchDataStore {
}

protocol AuthenticatorAppDataPassing {
    var dataStore: AuthenticatorAppDataStore? { get }
}

protocol AuthenticatorAppRoutes: CoordinatableRoutes {
}
