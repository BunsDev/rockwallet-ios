//
//  ItemSelectionVIP.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

extension Scenes {
    static let ItemSelection = ItemSelectionViewController.self
}

protocol ItemSelectionViewActions: BaseViewActions, FetchViewActions {
    func removePaymenetPopup(viewAction: ItemSelectionModels.RemovePaymenetPopup.ViewAction)
    func removePayment(viewAction: ItemSelectionModels.RemovePayment.ViewAction)
    func findAddress(viewAction: ItemSelectionModels.FindAddress.ViewAction)
}

protocol ItemSelectionActionResponses: BaseActionResponses, FetchActionResponses {
    func presentRemovePaymentPopup(actionResponse: ItemSelectionModels.RemovePaymenetPopup.ActionResponse)
    func presentRemovePaymentMessage(actionResponse: ItemSelectionModels.RemovePayment.ActionResponse)
}

protocol ItemSelectionResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayRemovePaymentPopup(responseDisplay: ItemSelectionModels.RemovePaymenetPopup.ResponseDisplay)
    func displayRemovePaymentSuccess(responseDisplay: ItemSelectionModels.RemovePayment.ResponseDisplay)
}

protocol ItemSelectionDataStore: BaseDataStore, FetchDataStore {
    var items: [any ItemSelectable]? { get set }
    var isAddingEnabled: Bool? { get set }
    var instrumentID: String? { get set }
    var sceneTitle: String { get set }
    var fromCardWithdrawal: Bool { get set }
}

protocol ItemSelectionDataPassing {
    var dataStore: (any ItemSelectionDataStore)? { get }
}

protocol ItemSelectionRoutes: CoordinatableRoutes {
}
