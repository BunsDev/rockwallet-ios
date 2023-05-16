// 
//  AsstetVIP.swift
//  breadwallet
//
//  Created by Rok on 09/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

protocol AssetViewActions {
    func getExchangeRate(viewAction: AssetModels.ExchangeRate.ViewAction, completion: (() -> Void)?)
    func getCoingeckoExchangeRate(viewAction: AssetModels.CoingeckoRate.ViewAction, completion: (() -> Void)?)
}

protocol AssetActionResponses {
    func presentExchangeRate(actionResponse: AssetModels.ExchangeRate.ActionResponse, completion: (() -> Void)?)
}

protocol AssetResponseDisplays {
    var tableView: ContentSizedTableView { get set }
    var continueButton: FEButton { get set }
    
    func getRateAndTimerCell() -> WrapperTableViewCell<ExchangeRateView>?
    func getAccountLimitsCell() -> WrapperTableViewCell<FELabel>?
    
    func displayExchangeRate(responseDisplay: AssetModels.ExchangeRate.ResponseDisplay, completion: (() -> Void)?)
}

protocol AssetDataStore: NSObject {
    var limits: NSMutableAttributedString? { get }
    var fromCode: String { get }
    var toCode: String { get }
    var quoteRequestData: QuoteRequestData { get }
    var quote: Quote? { get set }
    var showTimer: Bool { get set }
    var isFromBuy: Bool { get set }
    
    var secondFactorCode: String? { get set }
    var secondFactorBackup: String? { get set }
}

extension Interactor where Self: AssetViewActions,
                           Self.DataStore: AssetDataStore,
                           Self.ActionResponses: AssetActionResponses {
    func getExchangeRate(viewAction: AssetModels.ExchangeRate.ViewAction, completion: (() -> Void)?) {
        guard let fromCurrency = dataStore?.fromCode.uppercased(),
              let toCurrency = dataStore?.toCode.uppercased(),
              var data = dataStore?.quoteRequestData else { return }
        
        data.secondFactorCode = dataStore?.secondFactorCode
        data.secondFactorBackup = dataStore?.secondFactorBackup
        
        QuoteWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let quote):
                self?.dataStore?.quote = quote
                
                self?.presenter?.presentExchangeRate(actionResponse: .init(quote: quote,
                                                                           from: fromCurrency,
                                                                           to: toCurrency,
                                                                           limits: self?.dataStore?.limits,
                                                                           showTimer: self?.dataStore?.showTimer,
                                                                           isFromBuy: self?.dataStore?.isFromBuy), completion: {
                    if self?.dataStore?.isFromBuy == true {
                        completion?()
                    } else {
                        self?.getCoingeckoExchangeRate(viewAction: .init(getFees: viewAction.getFees), completion: completion)
                    }
                })
                
            case .failure(let error):
                self?.dataStore?.quote = nil
                
                completion?()
                
                self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noQuote(from: fromCurrency,
                                                                                                  to: toCurrency)))
            }
        }
    }
    
    func getCoingeckoExchangeRate(viewAction: AssetModels.CoingeckoRate.ViewAction, completion: (() -> Void)?) {}
}

extension Presenter where Self: AssetActionResponses,
                          Self.ResponseDisplays: AssetResponseDisplays {
    func presentExchangeRate(actionResponse: AssetModels.ExchangeRate.ActionResponse, completion: (() -> Void)?) {
        var exchangeRateViewModel: ExchangeRateViewModel
        if let from = actionResponse.from,
           let to = actionResponse.to,
           let quote = actionResponse.quote,
           let showTimer = actionResponse.showTimer,
           let isFromBuy = actionResponse.isFromBuy {
            var text: String
            if isFromBuy {
                text = String(format: "1 %@ = $%@ %@", to, RWFormatter().string(for: 1 / quote.exchangeRate) ?? "", from.uppercased())
            } else {
                text = String(format: "1 %@ = %@ %@", from.uppercased(), RWFormatter().string(for: quote.exchangeRate) ?? "", to)
            }
            
            exchangeRateViewModel = ExchangeRateViewModel(exchangeRate: text,
                                                          timer: TimerViewModel(till: quote.timestamp, repeats: false),
                                                          showTimer: showTimer)
        } else {
            exchangeRateViewModel = ExchangeRateViewModel(timer: nil, showTimer: false)
        }
        
        viewController?.displayExchangeRate(responseDisplay: .init(rateAndTimer: exchangeRateViewModel,
                                                                   accountLimits: .attributedText(actionResponse.limits)),
                                            completion: completion)
    }
}

extension Controller where Self: AssetResponseDisplays,
                           Self.ViewActions: AssetViewActions {
    func displayExchangeRate(responseDisplay: AssetModels.ExchangeRate.ResponseDisplay, completion: (() -> Void)?) {
        if let cell = getRateAndTimerCell(), let rateAndTimer = responseDisplay.rateAndTimer {
            cell.wrappedView.invalidate()
            
            cell.wrappedView.setup(with: rateAndTimer)
            cell.wrappedView.completion = { [weak self] in
                self?.interactor?.getExchangeRate(viewAction: .init(getFees: false), completion: {})
            }
        }
        
        if let cell = getAccountLimitsCell(), let accountLimits = responseDisplay.accountLimits {
            cell.wrappedView.setup(with: accountLimits)
        }
        
        var vm = continueButton.viewModel
        vm?.enabled = responseDisplay.rateAndTimer?.exchangeRate != nil
        continueButton.setup(with: vm)
        
        completion?()
    }
}
