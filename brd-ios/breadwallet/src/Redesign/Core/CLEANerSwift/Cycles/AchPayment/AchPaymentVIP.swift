//
//  AchPaymentVIP.swift
//  breadwallet
//
//  Created by Rok on 12/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import LinkKit

protocol AchViewActions {
    func getPayments(viewAction: AchPaymentModels.Get.ViewAction, completion: (() -> Void)?)
    func getPlaidToken(viewAction: AchPaymentModels.Link.ViewAction)
    func achSuccessMessage(viewAction: AchPaymentModels.Get.ViewAction)
}

protocol AchActionResponses: AnyObject {
    var achPaymentModel: CardSelectionViewModel? { get set }
    
    func presentPaymentCards(actionResponse: AchPaymentModels.PaymentCards.ActionResponse)
    func presentAch(actionResponse: AchPaymentModels.Get.ActionResponse)
    func presentPlaidToken(actionResponse: AchPaymentModels.Link.ActionResponse)
}

protocol AchResponseDisplays: AnyObject {
    var plaidHandler: PlaidLinkKitHandler? { get set }
    
    func displayPaymentCards(responseDisplay: AchPaymentModels.PaymentCards.ResponseDisplay)
    func displayAch(responseDisplay: AchPaymentModels.Get.ResponseDisplay)
    func displayPlaidToken(responseDisplay: AchPaymentModels.Link.ResponseDisplay)
}

protocol AchDataStore {
    var selected: PaymentCard? { get set }
    var ach: PaymentCard? { get set }
    var cards: [PaymentCard] { get set }
    var paymentMethod: PaymentCard.PaymentType? { get }
}

extension Interactor where Self: AchViewActions,
                           Self.DataStore: AchDataStore,
                           Self.ActionResponses: AchActionResponses {
    func getPayments(viewAction: AchPaymentModels.Get.ViewAction, completion: (() -> Void)?) {
        PaymentCardsWorker().execute(requestData: PaymentCardsRequestData()) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.ach = data?.first(where: { $0.type == .ach })
                self?.dataStore?.cards = data?.filter {$0.type == .card } ?? []
                
            default:
                break
            }
            
            if viewAction.openCards == true {
                self?.presenter?.presentPaymentCards(actionResponse: .init(allPaymentCards: self?.dataStore?.cards ?? []))
            } else {
                if self?.dataStore?.paymentMethod == .ach {
                    self?.presenter?.presentAch(actionResponse: .init(item: self?.dataStore?.ach))
                }
                
                completion?()
            }
        }
    }
    
    func getPlaidToken(viewAction: AchPaymentModels.Link.ViewAction) {
        guard dataStore?.ach == nil || dataStore?.ach?.status != .statusOk else { return }
        
        PlaidLinkTokenWorker().execute(requestData: PlaidLinkTokenRequestData(accountId: dataStore?.ach?.id)) { [weak self] result in
            switch result {
            case .success(let response):
                self?.getPublicPlaidToken(for: response?.linkToken)
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    private func getPublicPlaidToken(for token: String?) {
        guard let linkToken = token else { return }
        
        var linkConfiguration = LinkTokenConfiguration(token: linkToken) { [weak self] result in
            let publicToken = result.publicToken
            let mask = result.metadata.accounts.first?.mask
            self?.setPublicPlaidToken(publicToken, mask: mask)
        }
        
        linkConfiguration.onExit = { [weak self] exit in
            guard let data = self?.mapStructToDictionary(item: exit).description else {
                return
            }
            PlaidErrorWorker().execute(requestData: PlaidErrorRequestData(error: data))
        }
        
        linkConfiguration.onEvent = { [weak self] event in
            guard let data = self?.mapStructToDictionary(item: event).description else {
                return
            }
            PlaidEventWorker().execute(requestData: PlaidEventRequestData(event: data))
        }
        
        GoogleAnalytics.logEvent(GoogleAnalytics.OpenPlaid(configuration: String(describing: linkConfiguration)))
        
        let result = Plaid.create(linkConfiguration)
        switch result {
        case .failure(let error):
            presenter?.presentError(actionResponse: .init(error: error))
        case .success(let handler):
            presenter?.presentPlaidToken(actionResponse: .init(plaidHandler: handler))
        }
    }
    
    private func setPublicPlaidToken(_ token: String?, mask: String?) {
        PlaidPublicTokenWorker().execute(requestData: PlaidPublicTokenRequestData(publicToken: token,
                                                                                  mask: mask,
                                                                                  accountId: dataStore?.ach?.id)) { [weak self] result in
            switch result {
            case .success:
                self?.getPayments(viewAction: .init(), completion: { [weak self] in
                    self?.achSuccessMessage(viewAction: .init())
                })
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func mapStructToDictionary<T>(item: T) -> [String: Any] {
        let dictionary = Dictionary(uniqueKeysWithValues:
            Mirror(reflecting: item).children.lazy.map({ (label: String?, value: Any) in
                if let label = label {
                    return (label, value)
                } else {
                    return (Date().timeIntervalSince1970.description, value)
                }
            })
        )
        return dictionary.compactMapValues { $0 }
    }
}

extension Presenter where Self: AchActionResponses,
                          Self.ResponseDisplays: AchResponseDisplays {
    func presentPaymentCards(actionResponse: AchPaymentModels.PaymentCards.ActionResponse) {
        viewController?.displayPaymentCards(responseDisplay: .init(allPaymentCards: actionResponse.allPaymentCards))
    }
    
    func presentAch(actionResponse: AchPaymentModels.Get.ActionResponse) {
        guard let item = actionResponse.item else {
            achPaymentModel = .init(title: .text(L10n.Sell.achWithdrawal),
                                    subtitle: .text(L10n.Buy.linkBankAccount),
                                    userInteractionEnabled: true)
            return
        }
        
        switch item.status {
        case .statusOk:
            achPaymentModel = .init(title: .text(L10n.Sell.widrawToBank),
                                    subtitle: nil,
                                    logo: .image(Asset.bank.image),
                                    cardNumber: .text(item.displayName),
                                    userInteractionEnabled: false)
            
        default:
            achPaymentModel = .init(title: .text(L10n.Sell.achWithdrawal),
                                    subtitle: .text(L10n.Buy.relinkBankAccount),
                                    userInteractionEnabled: true)
        }
        
        viewController?.displayAch(responseDisplay: .init(viewModel: achPaymentModel))
    }
    
    func presentPlaidToken(actionResponse: AchPaymentModels.Link.ActionResponse) {
        viewController?.displayPlaidToken(responseDisplay: .init(plaidHandler: actionResponse.plaidHandler))
    }
}

extension Controller where Self: AchResponseDisplays {
    func displayPaymentCards(responseDisplay: AchPaymentModels.PaymentCards.ResponseDisplay) {
        view.endEditing(true)
        
        (coordinator as? ExchangeCoordinator)?.showCardSelector(cards: responseDisplay.allPaymentCards, selected: { [weak self] selectedCard in
            guard let selectedCard = selectedCard else { return }
            
            (self?.interactor as? AssetViewActions)?.setAmount(viewAction: .init(card: selectedCard))
        }, completion: { [weak self] in
            (self?.interactor as? AchViewActions)?.getPayments(viewAction: .init(), completion: {})
        })
    }
    
    func displayPlaidToken(responseDisplay: AchPaymentModels.Link.ResponseDisplay) {
        plaidHandler = responseDisplay.plaidHandler
        plaidHandler?.open(presentUsing: .viewController(self))
    }
    
    func displayAch(responseDisplay: AchPaymentModels.Get.ResponseDisplay) {}
}
