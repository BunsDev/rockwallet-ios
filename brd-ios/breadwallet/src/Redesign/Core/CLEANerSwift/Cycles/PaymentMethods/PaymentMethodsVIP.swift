//
//  PaymentMethodsVIP.swift
//  breadwallet
//
//  Created by Rok on 12/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import LinkKit

protocol PaymentMethodsViewActions {
    func getPayments(viewAction: PaymentMethodsModels.Get.ViewAction, completion: (() -> Void)?)
    func getPlaidToken(viewAction: PaymentMethodsModels.Link.ViewAction)
    func setPaymentCard(viewAction: PaymentMethodsModels.SetPaymentCard.ViewAction)
    func achSuccessMessage(viewAction: PaymentMethodsModels.Get.ViewAction)
}

protocol PaymentMethodsActionResponses: AnyObject {
    var achPaymentModel: CardSelectionViewModel? { get set }
    
    func presentPaymentCards(actionResponse: PaymentMethodsModels.PaymentCards.ActionResponse)
    func presentAch(actionResponse: PaymentMethodsModels.Get.ActionResponse)
    func presentPlaidToken(actionResponse: PaymentMethodsModels.Link.ActionResponse)
}

protocol AchResponseDisplays: AnyObject, AssetResponseDisplays {
    var plaidHandler: PlaidLinkKitHandler? { get set }
    
    func displayPaymentCards(responseDisplay: AchPaymentModels.PaymentCards.ResponseDisplay)
    func displayPlaidToken(responseDisplay: AchPaymentModels.Link.ResponseDisplay)
}

protocol PaymentMethodsDataStore {
    var selected: PaymentCard? { get set }
    var ach: PaymentCard? { get set }
    var cards: [PaymentCard] { get set }
    var paymentMethod: PaymentCard.PaymentType? { get }
}

extension Interactor where Self: PaymentMethodsViewActions,
                           Self.DataStore: PaymentMethodsDataStore,
                           Self.ActionResponses: PaymentMethodsActionResponses {
    func getPayments(viewAction: PaymentMethodsModels.Get.ViewAction, completion: (() -> Void)?) {
        var ach: PaymentCard?
        var cards: [PaymentCard] = []
        
        PaymentCardsWorker().execute(requestData: PaymentCardsRequestData()) { [weak self] result in
            switch result {
            case .success(let data):
                ach = data?.first(where: { $0.type == .ach })
                cards = data?.filter { $0.type == .card } ?? []
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
            
            if viewAction.openCards == true {
                self?.presenter?.presentPaymentCards(actionResponse: .init(allPaymentCards: self?.dataStore?.cards ?? []))
            } else {
                guard let paymentMethod = self?.dataStore?.paymentMethod else { return }
                
                switch paymentMethod {
                case .ach:
                    self?.dataStore?.ach = ach
                    self?.dataStore?.selected = ach
                    
                    self?.presenter?.presentAch(actionResponse: .init(item: ach))
                    
                case .card:
                    let card = cards.contains(where: { $0.id == self?.dataStore?.selected?.id }) ? self?.dataStore?.selected : cards.first
                    self?.setPaymentCard(viewAction: .init(card: card))
                    
                    self?.dataStore?.cards = cards
                    
                    (self as? AssetViewActions)?.setAmount(viewAction: .init())
                }
                
                completion?()
            }
        }
    }
    
    func setPaymentCard(viewAction: PaymentMethodsModels.SetPaymentCard.ViewAction) {
        dataStore?.selected = viewAction.card
    }
    
    func getPlaidToken(viewAction: PaymentMethodsModels.Link.ViewAction) {
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
            guard let data = self?.mapStructToDictionary(item: exit).description else { return }
            PlaidErrorWorker().execute(requestData: PlaidErrorRequestData(error: data))
        }
        
        linkConfiguration.onEvent = { [weak self] event in
            guard let data = self?.mapStructToDictionary(item: event).description else { return }
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
    
    private func mapStructToDictionary<T>(item: T) -> [String: Any] {
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
                          Self.ResponseDisplays: AchResponseDisplays,
                          Self.ResponseDisplays: AssetResponseDisplays {
    func presentPaymentCards(actionResponse: AchPaymentModels.PaymentCards.ActionResponse) {
        viewController?.displayPaymentCards(responseDisplay: .init(allPaymentCards: actionResponse.allPaymentCards))
    }
    
    func presentAch(actionResponse: PaymentMethodsModels.Get.ActionResponse) {
        guard let item = actionResponse.item else {
            achPaymentModel = .init(title: .text(L10n.Sell.achWithdrawal),
                                    subtitle: .text(L10n.Buy.linkBankAccount),
                                    userInteractionEnabled: true)
            return
        }
        
        switch item.status {
        case .statusOk:
            achPaymentModel = .init(title: .text(L10n.Buy.transferFromBank),
                                    subtitle: nil,
                                    logo: .image(Asset.bank.image),
                                    cardNumber: .text(item.displayName),
                                    userInteractionEnabled: false)
            
        default:
            achPaymentModel = .init(title: .text(L10n.Sell.achWithdrawal),
                                    subtitle: .text(L10n.Buy.relinkBankAccount),
                                    userInteractionEnabled: true)
        }
        
        viewController?.displayAmount(responseDisplay: .init(cardModel: achPaymentModel))
    }
    
    func presentPlaidToken(actionResponse: PaymentMethodsModels.Link.ActionResponse) {
        viewController?.displayPlaidToken(responseDisplay: .init(plaidHandler: actionResponse.plaidHandler))
    }
}

extension Controller where Self: PaymentMethodsResponseDisplays {
    func displayPaymentCards(responseDisplay: PaymentMethodsModels.PaymentCards.ResponseDisplay) {
        view.endEditing(true)
        
        (coordinator as? ExchangeCoordinator)?.showCardSelector(cards: responseDisplay.allPaymentCards, selected: { [weak self] selectedCard in
            guard let selectedCard else { return }
            (self?.interactor as? PaymentMethodsViewActions)?.setPaymentCard(viewAction: .init(card: selectedCard))
        })
    }
    
    func displayPlaidToken(responseDisplay: PaymentMethodsModels.Link.ResponseDisplay) {
        plaidHandler = responseDisplay.plaidHandler
        plaidHandler?.open(presentUsing: .viewController(self))
    }
}
