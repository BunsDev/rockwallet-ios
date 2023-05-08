//
//  SwapStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

class SwapStore: NSObject, BaseDataStore, SwapDataStore {
    
    // MARK: - ExchangeRateDataStore
    
    var fromCode: String { from?.currency.code ?? "" }
    var toCode: String { to?.currency.code ?? "" }
    var showTimer: Bool = true
    var quoteRequestData: QuoteRequestData {
        return .init(from: fromCode,
                     to: toCode)
    }
    
    // MARK: - SwapDataStore
    var itemId: String?
    
    var from: Amount?
    var to: Amount?
    var fromBuy = false
    
    var values: SwapModels.Amounts.ViewAction = .init()
    
    var fromFee: TransferFeeBasis?
    
    var quote: Quote?
    var fromRate: Decimal?
    var toRate: Decimal?
    
    var currencies: [Currency] = []
    var supportedCurrencies: [SupportedCurrency]?
    
    var defaultCurrencyCode: String?
    
    var baseCurrencies: [String] = []
    var termCurrencies: [String] = []
    var baseAndTermCurrencies: [[String]] = []
    
    var swap: Exchange?
    
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    var limits: NSMutableAttributedString? {
        guard let quote = quote,
              let minText = ExchangeFormatter.fiat.string(for: quote.minimumUsd),
              let maxText = ExchangeFormatter.fiat.string(for: quote.maximumUsd)
        else { return nil }
        
        return NSMutableAttributedString(string: L10n.Swap.swapLimits(minText, maxText))
    }
    
    // MARK: - Additional helpers
    
    var fromFeeAmount: Amount? {
        guard let value = fromFee,
              let currency = currencies.first(where: { $0.code == value.fee.currency.code.uppercased() }) else {
            return nil
        }
        return .init(cryptoAmount: value.fee, currency: currency)
    }
    
    var toFeeAmount: Amount? {
        guard let value = quote?.toFee,
              let fee = ExchangeFormatter.crypto.string(for: value.fee),
              let currency = currencies.first(where: { $0.code == value.currency.uppercased() }) else {
            return nil
        }
        return .init(tokenString: fee, currency: currency)
    }
}
