//
//  SellStore.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit
import WalletKit

class SellStore: NSObject, BaseDataStore, SellDataStore {
    // MARK: - CreateTransactionDataStore
    var fromFeeBasis: WalletKit.TransferFeeBasis?
    var senderValidationResult: SenderValidationResult?
    var sender: Sender?
    
    // MARK: - ExchangeRateDataStore
    
    var quote: Quote?
    
    var fromCode: String { fromAmount?.currency.code ?? "" }
    var toCode: String { Constant.usdCurrencyCode }
    var isFromBuy: Bool = true
    var showTimer: Bool = false
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
    var supportedCurrencies: [String]?
    
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    var limits: NSMutableAttributedString? {
        guard let quote = quote,
              let minText = ExchangeFormatter.fiat.string(for: quote.minimumUsd),
              let maxText = ExchangeFormatter.fiat.string(for: quote.maximumUsd)
        else { return nil }
        
        return NSMutableAttributedString(string: L10n.Sell.sellLimits(minText, maxText))
    }
    
    var fromAmount: Amount?
    var toAmount: Decimal? { return fromAmount?.fiatValue }
    
    var fromRate: Decimal?
    
    var exchange: Exchange?
    
    var createTransactionModel: CreateTransactionModels.Transaction.ViewAction?
    
    // MARK: - TwoStepDataStore
    
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    // MARK: - Additional helpers
    
    var fromFeeAmount: Amount? {
        guard let value = fromFeeBasis,
              let currency = currencies.first(where: { $0.code == value.fee.currency.code.uppercased() }) else {
            return nil
        }
        return .init(cryptoAmount: value.fee, currency: currency)
    }
    
    var isFormValid: Bool {
        guard let amount = fromAmount,
              amount.tokenValue > 0,
              selected != nil
        else {
            return false
        }
        
        if ach != nil && ach?.status != .statusOk {
            return false
        } else {
            return true
        }
    }
}
