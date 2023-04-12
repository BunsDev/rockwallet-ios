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
}

protocol PaymailAddressActionResponses: BaseActionResponses, FetchActionResponses {
    func presentPaymailPopup(actionResponse: PaymailAddressModels.InfoPopup.ActionResponse)
}

protocol PaymailAddressResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayPaymailPopup(responseDisplay: PaymailAddressModels.InfoPopup.ResponseDisplay)
}

protocol PaymailAddressDataStore: BaseDataStore {
}

protocol PaymailAddressDataPassing {
    var dataStore: (any PaymailAddressDataStore)? { get }
}

protocol PaymailAddressRoutes: CoordinatableRoutes {
}
