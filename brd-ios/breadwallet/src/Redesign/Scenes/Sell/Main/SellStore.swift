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
        // TODO: get from quote when updated
        let minText = ExchangeFormatter.fiat.string(for: 100) ?? ""
        let maxText = ExchangeFormatter.fiat.string(for: 200) ?? ""
        let lifetime = ExchangeFormatter.fiat.string(for: 1000) ?? ""
        
        return L10n.Scenes.Sell.disclaimer(minText, maxText, lifetime)
    }
    // MARK: - Aditional helpers
}
