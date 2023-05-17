//
//  SellVIP.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit
import WalletKit

extension Scenes {
    static let Sell = SellViewController.self
}

protocol SellViewActions: BaseViewActions,
                          FetchViewActions,
                          AssetViewActions,
                          AchViewActions,
                          CreateTransactionViewActions {
    func setAmount(viewAction: AssetModels.Asset.ViewAction)
    func showOrderPreview(viewAction: SellModels.OrderPreview.ViewAction)
    func navigateAssetSelector(viewAction: SellModels.AssetSelector.ViewAction)
    func selectPaymentMethod(viewAction: SellModels.PaymentMethod.ViewAction)
    func retryPaymentMethod(viewAction: SellModels.RetryPaymentMethod.ViewAction)
    func showLimitsInfo(viewAction: SellModels.LimitsInfo.ViewAction)
    func showInstantAchPopup(viewAction: SellModels.InstantAchPopup.ViewAction)
    func showAssetSelectionMessage(viewAction: SellModels.AssetSelectionMessage.ViewAction)
    func prepareFees(viewAction: SellModels.Fee.ViewAction)
}

protocol SellActionResponses: BaseActionResponses,
                              FetchActionResponses,
                              AssetActionResponses,
                              AchActionResponses {
    func presentPaymentCards(actionResponse: SellModels.PaymentCards.ActionResponse)
    func presentAmount(actionResponse: AssetModels.Asset.ActionResponse)
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
                               AssetResponseDisplays,
                               AchResponseDisplays {
    func displayPaymentCards(responseDisplay: SellModels.PaymentCards.ResponseDisplay)
    func displayAmount(responseDisplay: SellModels.Assets.ResponseDisplay)
    func displayOrderPreview(responseDisplay: SellModels.OrderPreview.ResponseDisplay)
    func displayNavigateAssetSelector(responseDisplay: SellModels.AssetSelector.ResponseDisplay)
    func displayAchData(responseDisplay: SellModels.AchData.ResponseDisplay)
    func displayLimitsInfo(responseDisplay: SellModels.LimitsInfo.ResponseDisplay)
    func displayInstantAchPopup(responseDisplay: SellModels.InstantAchPopup.ResponseDisplay)
    func displayAssetSelectionMessage(responseDisplay: SellModels.AssetSelectionMessage.ResponseDisplay)
}

protocol SellDataStore: BaseDataStore, FetchDataStore, AssetDataStore, AchDataStore, CreateTransactionDataStore {
    // MARK: - SellDataStore
    
    var availablePayments: [PaymentCard.PaymentType] { get set }
    
    var currencies: [Currency] { get set }
    var supportedCurrencies: [SupportedCurrency]? { get set }
    var coreSystem: CoreSystem? { get set }
    var keyStore: KeyStore? { get set }
    
    var fromRate: Decimal? { get set }
    
    var fromAmount: Amount? { get set }
    var values: AssetModels.Asset.ViewAction { get set }
    
    var exchange: Exchange? { get set }
    
    var createTransactionModel: CreateTransactionModels.Transaction.ViewAction? { get set }
}

protocol SellDataPassing {
    var dataStore: (any SellDataStore)? { get }
}

protocol SellRoutes: CoordinatableRoutes {
}
