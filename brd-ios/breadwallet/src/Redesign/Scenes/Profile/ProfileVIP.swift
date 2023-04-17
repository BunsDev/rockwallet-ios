//
//  ProfileVIP.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

extension Scenes {
    static let Profile = ProfileViewController.self
}

protocol ProfileViewActions: BaseViewActions, FetchViewActions {
    func showVerificationInfo(viewAction: ProfileModels.VerificationInfo.ViewAction)
    func navigate(viewAction: ProfileModels.Navigate.ViewAction)
    func getPaymentCards(viewAction: ProfileModels.PaymentCards.ViewAction)
    func logout(viewAction: ProfileModels.Logout.ViewAction)
}

protocol ProfileActionResponses: BaseActionResponses, FetchActionResponses {
    func presentVerificationInfo(actionResponse: ProfileModels.VerificationInfo.ActionResponse)
    func presentNavigation(actionResponse: ProfileModels.Navigate.ActionResponse)
    func presentPaymentCards(actionResponse: ProfileModels.PaymentCards.ActionResponse)
    func presentLogout(actionResponse: ProfileModels.Logout.ActionResponse)
}

protocol ProfileResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayVerificationInfo(responseDisplay: ProfileModels.VerificationInfo.ResponseDisplay)
    func displayNavigation(responseDisplay: ProfileModels.Navigate.ResponseDisplay)
    func displayPaymentCards(responseDisplay: ProfileModels.PaymentCards.ResponseDisplay)
}

protocol ProfileDataStore: BaseDataStore, FetchDataStore {
    var allPaymentCards: [PaymentCard]? { get set }
    var paymentCard: PaymentCard? { get set }
    var autoSelectDefaultPaymentMethod: Bool { get set }
}

protocol ProfileDataPassing {
    var dataStore: (any ProfileDataStore)? { get }
}

protocol ProfileRoutes: CoordinatableRoutes {
    func showSecuirtySettings()
    func showPreferences()
}
