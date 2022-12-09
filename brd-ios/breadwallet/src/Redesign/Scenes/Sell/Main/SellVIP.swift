//
//  SellVIP.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

extension Scenes {
    static let Sell = SellViewController.self
}

protocol SellViewActions: BaseViewActions, ExchangeRateViewActions {
    func setAmount(viewAction: SellModels.Amounts.ViewAction)
}

protocol SellActionResponses: BaseActionResponses, ExchangeRateActionResponses {
    func presentAmount(actionResponse: SellModels.Amounts.ActionResponse)
}

protocol SellResponseDisplays: AnyObject, BaseResponseDisplays, ExchangeRateResponseDisplays {
    func displayAmount(responseDisplay: SellModels.Amounts.ResponseDisplay)
}

protocol SellDataStore: BaseDataStore, ExchangeDataStore {
}

protocol SellDataPassing {
    var dataStore: SellDataStore? { get }
}

protocol SellRoutes: CoordinatableRoutes {
    func showOrderPreview(crypto: Amount?, quote: Quote?)
}
