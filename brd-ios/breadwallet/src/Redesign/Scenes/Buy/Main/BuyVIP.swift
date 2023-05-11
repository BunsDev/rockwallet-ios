//
//  BuyVIP.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//
//

import UIKit
import WalletKit

extension Scenes {
    static let Buy = BuyViewController.self
}

protocol BuyViewActions: BaseViewActions,
                         FetchViewActions,
                         FeeFetchable,
                         ExchangeRateViewActions,
                         AchViewActions {
    func setAmount(viewAction: BuyModels.Amounts.ViewAction)
    func setAssets(viewAction: BuyModels.Assets.ViewAction)
    func showOrderPreview(viewAction: BuyModels.OrderPreview.ViewAction)
    func navigateAssetSelector(viewAction: BuyModels.AssetSelector.ViewAction)
    func selectPaymentMethod(viewAction: BuyModels.PaymentMethod.ViewAction)
    func retryPaymentMethod(viewAction: BuyModels.RetryPaymentMethod.ViewAction)
    func showLimitsInfo(viewAction: BuyModels.LimitsInfo.ViewAction)
    func showInstantAchPopup(viewAction: BuyModels.InstantAchPopup.ViewAction)
    func showAssetSelectionMessage(viewAction: BuyModels.AssetSelectionMessage.ViewAction)
}

protocol BuyActionResponses: BaseActionResponses,
                             FetchActionResponses,
                             ExchangeRateActionResponses,
                             AchActionResponses {
    func presentPaymentCards(actionResponse: BuyModels.PaymentCards.ActionResponse)
    func presentAssets(actionResponse: BuyModels.Assets.ActionResponse)
    func presentOrderPreview(actionResponse: BuyModels.OrderPreview.ActionResponse)
    func presentNavigateAssetSelector(actionResponse: BuyModels.AssetSelector.ActionResponse)
    func presentMessage(actionResponse: BuyModels.RetryPaymentMethod.ActionResponse)
    func presentAchSuccess(actionResponse: BuyModels.AchSuccess.ActionResponse)
    func presentLimitsInfo(actionResponse: BuyModels.LimitsInfo.ActionResponse)
    func presentInstantAchPopup(actionResponse: BuyModels.InstantAchPopup.ActionResponse)
    func presentAssetSelectionMessage(actionResponse: BuyModels.AssetSelectionMessage.ActionResponse)
}

protocol BuyResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays, ExchangeRateResponseDisplays, AchResponseDisplays {
    func displayPaymentCards(responseDisplay: BuyModels.PaymentCards.ResponseDisplay)
    func displayAssets(responseDisplay: BuyModels.Assets.ResponseDisplay)
    func displayOrderPreview(responseDisplay: BuyModels.OrderPreview.ResponseDisplay)
    func displayNavigateAssetSelector(responseDisplay: BuyModels.AssetSelector.ResponseDisplay)
    func displayAchData(responseDisplay: BuyModels.AchData.ResponseDisplay)
    func displayLimitsInfo(responseDisplay: BuyModels.LimitsInfo.ResponseDisplay)
    func displayInstantAchPopup(responseDisplay: BuyModels.InstantAchPopup.ResponseDisplay)
    func displayAssetSelectionMessage(responseDisplay: BuyModels.AssetSelectionMessage.ResponseDisplay)
}

protocol BuyDataStore: BaseDataStore, FetchDataStore, ExchangeDataStore, AchDataStore {
    var showTimer: Bool { get set }
    var from: Decimal? { get set }
    var to: Decimal? { get set }
    var fromBuy: Bool { get set }
    var values: BuyModels.Amounts.ViewAction { get set }
    var toAmount: Amount? { get set }
    var currencies: [Currency] { get set }
    var supportedCurrencies: [SupportedCurrency]? { get set }
    var quote: Quote? { get set }
    var ach: PaymentCard? { get set }
    var selected: PaymentCard? { get set }
    var cards: [PaymentCard] { get set }
    var secondFactorCode: String? { get set }
    var secondFactorBackup: String? { get set }
    var coreSystem: CoreSystem? { get set }
    var keyStore: KeyStore? { get set }
    var paymentMethod: PaymentCard.PaymentType? { get set }
    var publicToken: String? { get set }
    var mask: String? { get set }
    var availablePayments: [PaymentCard.PaymentType] { get set }
}

protocol BuyDataPassing: AchDataStore {
    var dataStore: (any BuyDataStore)? { get }
}

protocol BuyRoutes: CoordinatableRoutes {
}
