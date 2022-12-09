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
    var quote: Quote?
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
        return L10n.Scenes.Sell.disclaimer("50 USD", "100 USD", "1000 USD")
    }
    // MARK: - Aditional helpers
}
