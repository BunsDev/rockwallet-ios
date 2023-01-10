//
//  SignInVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let SignIn = SignInViewController.self
}

protocol SignInViewActions: BaseViewActions, FetchViewActions {
}

protocol SignInActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol SignInResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol SignInDataStore: BaseDataStore, FetchDataStore {
}

protocol SignInDataPassing {
    var dataStore: SignInDataStore? { get }
}

protocol SignInRoutes: CoordinatableRoutes {
}
