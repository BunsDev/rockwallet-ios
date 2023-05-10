//
//  SellStore.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

class SellStore: NSObject, BaseDataStore, SellDataStore {
    
    // MARK: - ExchangeRateDataStore
    
    // WHAT
    var quote: Quote? = .init(quoteId: 5,
                              exchangeRate: 0.99,
                              timestamp: Date().timeIntervalSince1970,
                              minimumValue: 100,
                              maximumValue: 200,
                              minimumUsd: 100,
                              maximumUsd: 200)
    
    var fromCode: String { currency?.code ?? "" }
    var toCode: String { Constant.usdCurrencyCode }
    var fromBuy: Bool = false
    var showTimer: Bool = false
    var values: SellModels.Amounts.ViewAction = .init()
    var quoteRequestData: QuoteRequestData {
        return .init(from: fromCode,
                     to: toCode,
                     type: .sell)
    }
    
    // MARK: - SellDataStore
    
    var ach: PaymentCard?
    var selected: PaymentCard?
    var cards: [PaymentCard] = []
    var paymentMethod: PaymentCard.PaymentType? = .ach
    var availablePayments: [PaymentCard.PaymentType] = []
    
    var currencies: [Currency] = []
    var supportedCurrencies: [SupportedCurrency]?
    
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
    
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    // MARK: - Additional helpers
    
    var isFormValid: Bool {
        // TODO: remove after BE is ready
        return true
    }
}
