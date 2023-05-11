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
    func setAssets(viewAction: SellModels.Assets.ViewAction)
    func showOrderPreview(viewAction: SellModels.OrderPreview.ViewAction)
    func navigateAssetSelector(viewAction: SellModels.AssetSelector.ViewAction)
    func selectPaymentMethod(viewAction: SellModels.PaymentMethod.ViewAction)
    func retryPaymentMethod(viewAction: SellModels.RetryPaymentMethod.ViewAction)
    func showLimitsInfo(viewAction: SellModels.LimitsInfo.ViewAction)
    func showInstantAchPopup(viewAction: SellModels.InstantAchPopup.ViewAction)
    func showAssetSelectionMessage(viewAction: SellModels.AssetSelectionMessage.ViewAction)
}

protocol SellActionResponses: BaseActionResponses,
                              FetchActionResponses,
                              ExchangeRateActionResponses,
                              AchActionResponses {
    func presentPaymentCards(actionResponse: SellModels.PaymentCards.ActionResponse)
    func presentAssets(actionResponse: SellModels.Assets.ActionResponse)
    func presentOrderPreview(actionResponse: SellModels.OrderPreview.ActionResponse)
    func presentNavigateAssetSelector(actionResponse: SellModels.AssetSelector.ActionResponse)
    func presentMessage(actionResponse: SellModels.RetryPaymentMethod.ActionResponse)
    func presentAchSuccess(actionResponse: SellModels.AchSuccess.ActionResponse)
    func presentLimitsInfo(actionResponse: SellModels.LimitsInfo.ActionResponse)
    func presentInstantAchPopup(actionResponse: SellModels.InstantAchPopup.ActionResponse)
    func presentAssetSelectionMessage(actionResponse: SellModels.AssetSelectionMessage.ActionResponse)
}

protocol SellResponseDisplays: AnyObject,
                               BaseResponseDisplays,
                               FetchResponseDisplays,
                               ExchangeRateResponseDisplays,
                               AchResponseDisplays {
    func displayPaymentCards(responseDisplay: SellModels.PaymentCards.ResponseDisplay)
    func displayAssets(responseDisplay: SellModels.Assets.ResponseDisplay)
    func displayOrderPreview(responseDisplay: SellModels.OrderPreview.ResponseDisplay)
    func displayNavigateAssetSelector(responseDisplay: SellModels.AssetSelector.ResponseDisplay)
    func displayAchData(responseDisplay: SellModels.AchData.ResponseDisplay)
    func displayLimitsInfo(responseDisplay: SellModels.LimitsInfo.ResponseDisplay)
    func displayInstantAchPopup(responseDisplay: SellModels.InstantAchPopup.ResponseDisplay)
    func displayAssetSelectionMessage(responseDisplay: SellModels.AssetSelectionMessage.ResponseDisplay)
}

protocol SellDataStore: BaseDataStore, FetchDataStore, ExchangeDataStore, AchDataStore {
    var quote: Quote? { get set }
    
    var fromBuyOrSell: Bool { get set }
    var showTimer: Bool { get set }
    
    // MARK: - SellDataStore
    
    var ach: PaymentCard? { get set }
    var selected: PaymentCard? { get set }
    var cards: [PaymentCard] { get set }
    var paymentMethod: PaymentCard.PaymentType? { get set }
    var availablePayments: [PaymentCard.PaymentType] { get set }
    
    var currencies: [Currency] { get set }
    var supportedCurrencies: [SupportedCurrency]? { get set }
    var coreSystem: CoreSystem? { get set }
    var keyStore: KeyStore? { get set }
    
    var fromAmount: Amount? { get set }
    var values: SellModels.Amounts.ViewAction { get set }
}

protocol SellDataPassing {
    var dataStore: (any SellDataStore)? { get }
}

protocol SellRoutes: CoordinatableRoutes {
}
