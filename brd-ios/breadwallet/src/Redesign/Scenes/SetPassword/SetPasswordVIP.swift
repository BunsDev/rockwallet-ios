//
//  SetPasswordVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let SetPassword = SetPasswordViewController.self
}

protocol SetPasswordViewActions: BaseViewActions, FetchViewActions {
    func validate(viewAction: SetPasswordModels.Validate.ViewAction)
    func next(viewAction: SetPasswordModels.Next.ViewAction)
}

protocol SetPasswordActionResponses: BaseActionResponses, FetchActionResponses {
    func presentValidate(actionResponse: SetPasswordModels.Validate.ActionResponse)
    func presentNext(actionResponse: SetPasswordModels.Next.ActionResponse)
}

protocol SetPasswordResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayValidate(responseDisplay: SetPasswordModels.Validate.ResponseDisplay)
    func displayNext(responseDisplay: SetPasswordModels.Next.ResponseDisplay)
}

protocol SetPasswordDataStore: BaseDataStore, FetchDataStore {
    var password: String { get set }
    var passwordAgain: String { get set }
    var code: String? { get set }
}

protocol SetPasswordDataPassing {
    var dataStore: SetPasswordDataStore? { get }
}

protocol SetPasswordRoutes: CoordinatableRoutes {
}
