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
}

protocol SellActionResponses: BaseActionResponses, ExchangeRateActionResponses {
}

protocol SellResponseDisplays: AnyObject, BaseResponseDisplays, ExchangeRateResponseDisplays {
}

protocol SellDataStore: BaseDataStore, ExchangeDataStore {
}

protocol SellDataPassing {
    var dataStore: SellDataStore? { get }
}

protocol SellRoutes: CoordinatableRoutes {
}
