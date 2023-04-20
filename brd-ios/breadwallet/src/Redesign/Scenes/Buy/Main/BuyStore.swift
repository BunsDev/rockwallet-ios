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
            guard let currency = Store.state.currencies.first(where: {
                $0.code.lowercased() == Constant.USDT.lowercased()
            }) ?? Store.state.currencies.first  else { return  }
            
            toAmount = .zero(currency)
        }
    }
    var publicToken: String?
    var mask: String?
    var limits: NSMutableAttributedString? {
        guard let quote = quote,
              let minText = ExchangeFormatter.fiat.string(for: quote.minimumUsd),
              let maxTextCard = UserManager.shared.profile?.buyAllowanceDailyMax.description,
              let maxTextAch = UserManager.shared.profile?.achAllowanceDailyMax.description else { return nil }
        
        let maxText = paymentMethod == .card ? maxTextCard : maxTextAch
        let moreInfo: String = isCustomLimits ? L10n.Button.moreInfo : ""
        
        let limitsString = NSMutableAttributedString(string: L10n.Buy.buyLimits(minText, maxText, moreInfo))
        
        guard isCustomLimits else { return limitsString }
        
        let moreInfoRange = limitsString.mutableString.range(of: moreInfo)
        limitsString.addAttribute(.underlineStyle, value: 1, range: moreInfoRange)
        limitsString.addAttribute(.font, value: Fonts.Subtitle.three, range: moreInfoRange)
        limitsString.addAttribute(.foregroundColor, value: LightColors.secondary, range: moreInfoRange)
        
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
