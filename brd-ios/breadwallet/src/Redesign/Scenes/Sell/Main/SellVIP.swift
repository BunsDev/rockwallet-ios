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

protocol SellViewActions: BaseViewActions,
                          FetchViewActions,
                          ExchangeRateViewActions,
                          AchViewActions {
    func setAmount(viewAction: SellModels.Amounts.ViewAction)
}

protocol SellActionResponses: BaseActionResponses,
                              FetchActionResponses,
                              ExchangeRateActionResponses,
                              AchActionResponses {
    func presentAmount(actionResponse: SellModels.Amounts.ActionResponse)
}

protocol SellResponseDisplays: AnyObject,
                               BaseResponseDisplays,
                               FetchResponseDisplays,
                               ExchangeRateResponseDisplays,
                               AchResponseDisplays {
}

protocol SellDataStore: BaseDataStore, FetchDataStore, ExchangeDataStore, AchDataStore {
    var quote: Quote? { get set }
    
    var fromBuy: Bool { get set }
    var showTimer: Bool { get set }
    
    // MARK: - SellDataStore
    
    var ach: PaymentCard? { get set }
    var selected: PaymentCard? { get set }
    var cards: [PaymentCard] { get set }
    var paymentMethod: PaymentCard.PaymentType? { get set }
    
    var currencies: [Currency] { get set }
    var supportedCurrencies: [SupportedCurrency]? { get set }
    var currency: Currency? { get set }
    var coreSystem: CoreSystem? { get set }
    var keyStore: KeyStore? { get set }
    
    var fromAmount: Amount? { get set }
    
    var secondFactorCode: String? { get set }
    var secondFactorBackup: String? { get set }
}

protocol SellDataPassing {
    var dataStore: (any SellDataStore)? { get }
}

protocol SellRoutes: CoordinatableRoutes {
}
