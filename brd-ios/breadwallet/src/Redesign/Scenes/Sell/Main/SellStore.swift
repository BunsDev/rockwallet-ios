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
    var fromBuy = false
    var showTimer: Bool = false
    var quoteRequestData: QuoteRequestData {
        return .init(from: fromCode,
                     to: toCode,
                     type: .sell)
    }
    
    // MARK: - AchDataStore
    var ach: PaymentCard?
    var selected: PaymentCard?
    var cards: [PaymentCard] = []
    var paymentMethod: PaymentCard.PaymentType? = .ach
    
    var currency: Currency?
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    var limits: NSMutableAttributedString? {
        guard let quote = quote,
              let minText = ExchangeFormatter.fiat.string(for: quote.minimumUsd),
              let maxText = ExchangeFormatter.fiat.string(for: quote.maximumUsd),
              let lifetimeLimit = ExchangeFormatter.fiat.string(for: UserManager.shared.profile?.achAllowanceLifetime)
        else { return nil }
        
        return NSMutableAttributedString(string: L10n.Sell.sellLimits(minText, maxText, lifetimeLimit))
    }
    
    var fromAmount: Amount?
    var toAmount: Decimal? { return fromAmount?.fiatValue }
    
    // MARK: - Aditional helpers
    var isFormValid: Bool {
        // TODO: remove after BE is ready
        return true
    }
}
