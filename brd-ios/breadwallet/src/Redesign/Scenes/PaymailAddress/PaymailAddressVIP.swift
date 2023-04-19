//
//  PaymailAddressVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.4.23.
//
//

import UIKit

extension Scenes {
    static let PaymailAddress = PaymailAddressViewController.self
}

protocol PaymailAddressViewActions: BaseViewActions, FetchViewActions {
    func showPaymailPopup(viewAction: PaymailAddressModels.InfoPopup.ViewAction)
    func showSuccessBottomAlert(viewAction: PaymailAddressModels.Success.ViewAction)
}

protocol PaymailAddressActionResponses: BaseActionResponses, FetchActionResponses {
    func presentPaymailPopup(actionResponse: PaymailAddressModels.InfoPopup.ActionResponse)
    func presentSuccessBottomAlert(actionResponse: PaymailAddressModels.Success.ActionResponse)
}

protocol PaymailAddressResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayPaymailPopup(responseDisplay: PaymailAddressModels.InfoPopup.ResponseDisplay)
    func displaySuccessBottomAlert(responseDisplay: PaymailAddressModels.Success.ResponseDisplay)
}

protocol PaymailAddressDataStore: BaseDataStore {
    var screenType: PaymailAddressModels.ScreenType? { get set }
}

protocol PaymailAddressDataPassing {
    var dataStore: (any PaymailAddressDataStore)? { get }
}

protocol PaymailAddressRoutes: CoordinatableRoutes {
}
