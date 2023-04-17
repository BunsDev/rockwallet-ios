//
//  TwoStepAuthenticationVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 27/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let TwoStepAuthentication = TwoStepAuthenticationViewController.self
}

protocol TwoStepAuthenticationViewActions: BaseViewActions, FetchViewActions {
}

protocol TwoStepAuthenticationActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol TwoStepAuthenticationResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol TwoStepAuthenticationDataStore: BaseDataStore, FetchDataStore {
    var keyStore: KeyStore? { get set }
}

protocol TwoStepAuthenticationDataPassing {
    var dataStore: (any TwoStepAuthenticationDataStore)? { get }
}

protocol TwoStepAuthenticationRoutes: CountriesAndStatesRoutes {
}
