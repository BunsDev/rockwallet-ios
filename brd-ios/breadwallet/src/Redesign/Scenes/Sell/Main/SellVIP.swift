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

protocol SellViewActions: BaseViewActions {
}

protocol SellActionResponses: BaseActionResponses {
}

protocol SellResponseDisplays: AnyObject, BaseResponseDisplays {
}

protocol SellDataStore: BaseDataStore {
}

protocol SellDataPassing {
    var dataStore: SellDataStore? { get }
}

protocol SellRoutes: CoordinatableRoutes {
}
