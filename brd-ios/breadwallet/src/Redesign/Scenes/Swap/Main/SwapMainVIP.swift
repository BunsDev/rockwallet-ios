//
//  SwapVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

extension Scenes {
    static let Swap = SwapViewController.self
}

protocol SwapViewActions: BaseViewActions, FetchViewActions, FeeFetchable, ExchangeRateViewActions {
    func setAmount(viewAction: SwapModels.Amounts.ViewAction)
    func switchPlaces(viewAction: SwapModels.SwitchPlaces.ViewAction)
    func selectAsset(viewAction: SwapModels.Assets.ViewAction)
    func showConfirmation(viewAction: SwapModels.ShowConfirmDialog.ViewAction)
    func confirm(viewAction: SwapModels.Confirm.ViewAction)
    func showAssetInfoPopup(viewAction: SwapModels.AssetInfoPopup.ViewAction)
    func showAssetSelectionMessage(viewAction: SwapModels.AssetSelectionMessage.ViewAction)
}

protocol SwapActionResponses: BaseActionResponses, FetchActionResponses, ExchangeRateActionResponses {
    func presentAmount(actionResponse: SwapModels.Amounts.ActionResponse)
    func presentSelectAsset(actionResponse: SwapModels.Assets.ActionResponse)
    func presentConfirmation(actionResponse: SwapModels.ShowConfirmDialog.ActionResponse)
    func presentConfirm(actionResponse: SwapModels.Confirm.ActionResponse)
    func presentAssetInfoPopup(actionResponse: SwapModels.AssetInfoPopup.ActionResponse)
    func presentAssetSelectionMessage(actionResponse: SwapModels.AssetSelectionMessage.ActionResponse)
}

protocol SwapResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays, ExchangeRateResponseDisplays {
    func displaySelectAsset(responseDisplay: SwapModels.Assets.ResponseDisplay)
    func displayConfirmation(responseDisplay: SwapModels.ShowConfirmDialog.ResponseDisplay)
    func displayConfirm(responseDisplay: SwapModels.Confirm.ResponseDisplay)
    func displayAssetInfoPopup(responseDisplay: SwapModels.AssetInfoPopup.ResponseDisplay)
    func displayError(responseDisplay: SwapModels.ErrorPopup.ResponseDisplay)
    func displayAssetSelectionMessage(responseDisplay: SwapModels.AssetSelectionMessage.ResponseDisplay)
}

protocol SwapDataStore: BaseDataStore, FetchDataStore, ExchangeDataStore {
    var from: Amount? { get set }
    var to: Amount? { get set }
    
    var values: SwapModels.Amounts.ViewAction { get set }
    
    var fromFee: TransferFeeBasis? { get set }
    
    var quote: Quote? { get set }
    
    var fromRate: Decimal? { get set }
    var toRate: Decimal? { get set }
    
    var baseCurrencies: [String] { get set }
    var termCurrencies: [String] { get set }
    var baseAndTermCurrencies: [[String]] { get set }
    
    var currencies: [Currency] { get set }
    var supportedCurrencies: [SupportedCurrency]? { get set }
    
    var coreSystem: CoreSystem? { get set }
    var keyStore: KeyStore? { get set }
}

protocol SwapDataPassing {
    var dataStore: (any SwapDataStore)? { get }
}

protocol SwapRoutes: CoordinatableRoutes {
    func showAssetSelector(title: String, currencies: [Currency]?, supportedCurrencies: [SupportedCurrency]?, selected: ((Any?) -> Void)?)
    func showPinInput(keyStore: KeyStore?, callback: ((_ success: Bool) -> Void)?)
    func showSwapInfo(from: String, to: String, exchangeId: String)
}
