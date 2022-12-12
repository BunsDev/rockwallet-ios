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

protocol AchPaymentViewActions: FetchViewActions {
    func linkAch(viewAction: ExchangeRateModels.CoingeckoRate.ViewAction)
    func relinkAch(viewAction: ExchangeRateModels.CoingeckoRate.ViewAction)
    func selectAch(viewAction: ExchangeRateModels.CoingeckoRate.ViewAction)
}

protocol AchPaymentActionResponses {
    func presentExchangeRate(actionResponse: ExchangeRateModels.ExchangeRate.ActionResponse)
}

protocol AchPaymentResponseDisplays {
}

protocol AchPaymentSelectionDataStore: NSObject {
}


extension Interactor where Self: AchPaymentViewActions {
    func selectCard(viewAction: ExchangeRateModels.CoingeckoRate.ViewAction) {
        
    }
    
    func addCard(viewAction: ExchangeRateModels.CoingeckoRate.ViewAction) {
        
    }
    
    func removeCard(viewAction: ExchangeRateModels.CoingeckoRate.ViewAction) {
        
    }
    
    func linkAch(viewAction: ExchangeRateModels.CoingeckoRate.ViewAction) {
        
    }
    
    func relinkAch(viewAction: ExchangeRateModels.CoingeckoRate.ViewAction) {
        
    }
}



if paymentSegment.selectedIndex == .buyAch && hasAch {
    paymentMethodViewModel = CardSelectionViewModel(title: .text(L10n.Buy.achPayments),
                                                    subtitle: .text(L10n.Buy.linkBankAccount),
                                                    userInteractionEnabled: true)
    switch actionResponse.card?.status {
    case .statusOk:
        cardModel = .init(title: .text(L10n.Buy.transferFromBank),
                          subtitle: nil,
                          logo: .image(Asset.bank.image),
                          cardNumber: .text(paymentCard.displayName),
                          userInteractionEnabled: false)
        
    default:
        cardModel = .init(title: .text(L10n.Buy.achPayments),
                          subtitle: .text(L10n.Buy.relinkBankAccount),
                          userInteractionEnabled: true)
    }
    cryptoModel.selectionDisabled = true
    
} else if actionResponse.paymentMethod == .buyCard {
    cardModel = .init(userInteractionEnabled: true)
} else {
    cardModel = CardSelectionViewModel(title: .text(L10n.Buy.achPayments),
                                       subtitle: .text(L10n.Buy.linkBankAccount),
                                       userInteractionEnabled: true)
    cryptoModel.selectionDisabled = true
}
viewController?.displayAssets(responseDisplay: .init(cryptoModel: cryptoModel, cardModel: cardModel))
