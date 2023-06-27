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
    var accountId: String? { return ach?.id }
    var quoteRequestData: QuoteRequestData {
        return .init(from: fromCode.lowercased(),
                     to: toCode,
                     type: .buy(paymentMethod),
                     accountId: paymentMethod == .ach ? accountId : nil)
    }
    
    // MARK: - BuyDataStore
    
    var from: Decimal?
    var to: Decimal?
    var isFromBuy: Bool = true
    var paymentMethod: PaymentCard.PaymentType?
    var publicToken: String?
    var mask: String?
    var limits: NSMutableAttributedString? {
        guard let quote = quote,
              let minText = ExchangeFormatter.fiat.string(for: quote.minimumUsd),
              let weeklyCardText = ExchangeFormatter.fiat.string(for: UserManager.shared.profile?.buyAllowanceWeekly),
              let weeklyAchText = ExchangeFormatter.fiat.string(for: UserManager.shared.profile?.buyAllowanceWeekly) else { return nil }
        
        let limits: String
        let limitsString: NSMutableAttributedString
        
        switch paymentMethod {
        case .card:
            limits = L10n.Buy.buyLimits(minText, Constant.usdCurrencyCode, weeklyCardText, Constant.usdCurrencyCode)
            limitsString = NSMutableAttributedString(string: limits + "\n\n" + L10n.Buy.BuyLimits.increase)
            
        case .ach:
            limits = L10n.Buy.buyLimits(minText, Constant.usdCurrencyCode, weeklyAchText, Constant.usdCurrencyCode)
            limitsString = NSMutableAttributedString(string: limits + "\n\n" + L10n.Buy.achBuyDisclaimer)
            
        default:
            limits = ""
            limitsString = .init(string: "")
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
    
    // MARK: - PaymentMethodsDataStore
    var ach: PaymentCard?
    var selected: PaymentCard?
    var cards: [PaymentCard] = []
    
    var quote: Quote?
    
    var currencies: [Currency] = []
    var supportedCurrencies: [String]?
    
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    
    var sender: Sender?
    var fromFeeBasis: WalletKit.TransferFeeBasis?
    var senderValidationResult: SenderValidationResult?
    
    var canUseAch = UserManager.shared.profile?.kycAccessRights.hasAchAccess
    
    // MARK: - TwoStepDataStore
    
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    var availablePayments: [PaymentCard.PaymentType] = []
    
    // MARK: - Additional helpers
    
    var isFormValid: Bool {
        guard let amount = toAmount,
              amount.tokenValue > 0,
              selected != nil,
              feeAmount != nil,
              feeAmount != nil,
              isPaymentMethodProblematic == false
        else {
            return false
        }
        return true
    }
    
    func isCustomLimits(for paymentMethod: PaymentCard.PaymentType?) -> Bool {
        guard let limits = UserManager.shared.profile?.limits else { return false }
        
        switch paymentMethod {
        case .card:
            return limits.first(where: { ($0.interval == .weekly || $0.interval == .monthly) && $0.exchangeType == .buyCard })?.isCustom ?? false
            
        case .ach:
            return limits.first(where: { ($0.interval == .weekly || $0.interval == .monthly) && $0.exchangeType == .buyAch })?.isCustom ?? false
            
        default:
            return false
        }
    }
    
    private var isPaymentMethodProblematic: Bool {
        switch paymentMethod {
        case .card:
            return selected?.paymentMethodStatus.isProblematic ?? true
            
        case .ach:
            return ach?.paymentMethodStatus.isProblematic ?? true
            
        default:
            return true
        }
    }
}
