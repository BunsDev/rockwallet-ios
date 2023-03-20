//
//  VerifyPhoneNumberVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let VerifyPhoneNumber = VerifyPhoneNumberViewController.self
}

protocol VerifyPhoneNumberViewActions: BaseViewActions, FetchViewActions {
    func validate(viewAction: VerifyPhoneNumberModels.Validate.ViewAction)
    func confirm(viewAction: VerifyPhoneNumberModels.Confirm.ViewAction)
    func resend(viewAction: VerifyPhoneNumberModels.Resend.ViewAction)
}

protocol VerifyPhoneNumberActionResponses: BaseActionResponses, FetchActionResponses {
    func presentConfirm(actionResponse: VerifyPhoneNumberModels.Confirm.ActionResponse)
    func presentResend(actionResponse: VerifyPhoneNumberModels.Resend.ActionResponse)
}

protocol VerifyPhoneNumberResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayConfirm(responseDisplay: VerifyPhoneNumberModels.Confirm.ResponseDisplay)
}

protocol VerifyPhoneNumberDataStore: BaseDataStore, FetchDataStore {
}

protocol VerifyPhoneNumberDataPassing {
    var dataStore: VerifyPhoneNumberDataStore? { get }
}

protocol VerifyPhoneNumberRoutes: CoordinatableRoutes {
}
