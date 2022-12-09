//
//  SellStore.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

class SellStore: NSObject, BaseDataStore, SellDataStore {
    
    // MARK: - SellDataStore
    
    // ExchangeRateDaatStore
    var quote: Quote? = .init(quoteId: 5,
                              exchangeRate: 0.99,
                              timestamp: Date().timeIntervalSince1970,
                              minimumValue: 100,
                              maximumValue: 200,
                              minimumUsd: 100,
                              maximumUsd: 200)
    
    var fromCode: String { currency?.code ?? "" }
    var toCode: String { C.usdCurrencyCode }
    var quoteRequestData: QuoteRequestData {
        return .init(from: fromCode,
                     to: toCode,
                     type: .sell)
    }
    
    var currency: Currency?
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    var limits: String {
        guard let quote = quote else { return "" }
        let minText = ExchangeFormatter.fiat.string(for: quote.minimumValue) ?? ""
        let maxText = ExchangeFormatter.fiat.string(for: quote.maximumValue) ?? ""
        let lifetimeLimit = ExchangeFormatter.fiat.string(for: UserManager.shared.profile?.achLifetimeRemainingLimit) ?? ""
        
        return L10n.Scenes.Sell.disclaimer(minText, maxText, lifetimeLimit)
    }
    
    var fromAmount: Amount?
    var toAmount: Decimal? { return fromAmount?.fiatValue }
    // MARK: - Aditional helpers
}
