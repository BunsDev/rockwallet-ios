//
//  BuyStore.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//
//

import UIKit
import WalletKit

class BuyStore: NSObject, BaseDataStore, BuyDataStore {
    
    // MARK: - ExchangeRateDataStore
    var fromCode: String { return Constant.usdCurrencyCode }
    var toCode: String { toAmount?.currency.code ?? "" }
    var showTimer: Bool = false
    var quoteRequestData: QuoteRequestData {
        return .init(from: fromCode.lowercased(),
                     to: toCode,
                     type: .buy(paymentMethod))
    }
    
    // MARK: - BuyDataStore
    var itemId: String?
    
    var from: Decimal?
    var to: Decimal?
    var fromBuy = true
    var values: BuyModels.Amounts.ViewAction = .init()
    var paymentMethod: PaymentCard.PaymentType? {
        didSet {
            guard toAmount == nil else { return }
            let selectedCurrency: Currency
            if paymentMethod == .ach {
                guard let currency = Store.state.currencies.first(where: { $0.code == Constant.USDT }) else { return }
                selectedCurrency = currency
            } else {
                guard let currency = Store.state.currencies.first(where: {
                    $0.code.lowercased() == Constant.BTC.lowercased()
                }) ?? Store.state.currencies.first  else { return  }
                selectedCurrency = currency
            }
            
            toAmount = .zero(selectedCurrency)
        }
    }
    var publicToken: String?
    var mask: String?
    var limits: NSMutableAttributedString? {
        guard let quote = quote,
              let minText = ExchangeFormatter.fiat.string(for: quote.minimumUsd),
              let maxTextCard = UserManager.shared.profile?.buyAllowanceDailyMax.description,
              let maxTextAch = UserManager.shared.profile?.achAllowanceDailyMax.description,
              let lifetimeLimit = ExchangeFormatter.fiat.string(for: UserManager.shared.profile?.achAllowanceLifetime)
        else { return nil }
        
        let maxText = paymentMethod == .card ? maxTextCard : maxTextAch
        let limitsString = NSMutableAttributedString(string: paymentMethod == .ach ?
                                                     L10n.Buy.achLimits(minText, maxText, lifetimeLimit) : L10n.Buy.buyLimits(minText, maxText))
        
        let linkRange = limitsString.mutableString.range(of: L10n.Button.moreInfo)
        
        if isCustomLimits {
            if linkRange.location != NSNotFound {
                limitsString.addAttribute(.underlineStyle, value: 1, range: linkRange)
            }
        } else {
            limitsString.replaceCharacters(in: linkRange, with: "")
        }
        
        return limitsString
    }
    
    var feeAmount: Amount? {
        guard let value = quote?.toFee,
              let currency = currencies.first(where: { $0.code == value.currency.uppercased() }) else {
            return nil
        }
        return .init(decimalAmount: value.fee, isFiat: false, currency: currency, exchangeRate: quote?.exchangeRate)
    }
    
    var toAmount: Amount?
    
    // MARK: - AchDataStore
    var ach: PaymentCard?
    var selected: PaymentCard?
    var cards: [PaymentCard] = []
    
    var quote: Quote?
    
    var currencies: [Currency] = Store.state.currencies
    var supportedCurrencies: [SupportedCurrency]?
    
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    var autoSelectDefaultPaymentMethod = true
    var canUseAch = UserManager.shared.profile?.kycAccessRights.hasAchAccess
    
    // MARK: - Aditional helpers
    
    var isFormValid: Bool {
        guard let amount = toAmount,
              amount.tokenValue > 0,
              selected != nil,
              feeAmount != nil,
              feeAmount != nil
        else {
            return false
        }
        return true
    }
    
    var isCustomLimits: Bool {
        guard let limits = UserManager.shared.profile?.limits else { return false }
        
        let isCustom = paymentMethod == .ach ?
        limits.first(where: { ($0.interval == .weekly || $0.interval == .monthly) && $0.exchangeType == .buyAch })?.isCustom ?? false :
        limits.first(where: { ($0.interval == .weekly || $0.interval == .monthly) && $0.exchangeType == .buyCard })?.isCustom ?? false
        
        return isCustom
    }
    
    var availablePayments: [PaymentCard.PaymentType] = []
}
