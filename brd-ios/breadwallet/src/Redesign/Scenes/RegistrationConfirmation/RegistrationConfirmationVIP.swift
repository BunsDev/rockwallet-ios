//
//  RegistrationConfirmationVIP.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

extension Scenes {
    static let RegistrationConfirmation = RegistrationConfirmationViewController.self
}

protocol RegistrationConfirmationViewActions: BaseViewActions, FetchViewActions {
    func validate(viewAction: RegistrationConfirmationModels.Validate.ViewAction)
    func confirm(viewAction: RegistrationConfirmationModels.Confirm.ViewAction)
    func resend(viewAction: RegistrationConfirmationModels.Resend.ViewAction)
}

protocol RegistrationConfirmationActionResponses: BaseActionResponses, FetchActionResponses {
    func presentConfirm(actionResponse: RegistrationConfirmationModels.Confirm.ActionResponse)
    func presentResend(actionResponse: RegistrationConfirmationModels.Resend.ActionResponse)
    func presentError(actionResponse: RegistrationConfirmationModels.Error.ActionResponse)
}

protocol RegistrationConfirmationResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayConfirm(responseDisplay: RegistrationConfirmationModels.Confirm.ResponseDisplay)
    func displayError(responseDisplay: RegistrationConfirmationModels.Error.ResponseDisplay)
}

protocol RegistrationConfirmationDataStore: BaseDataStore, FetchDataStore {
}

protocol RegistrationConfirmationDataPassing {
    var dataStore: RegistrationConfirmationDataStore? { get }
}

protocol RegistrationConfirmationRoutes: CoordinatableRoutes {
}
