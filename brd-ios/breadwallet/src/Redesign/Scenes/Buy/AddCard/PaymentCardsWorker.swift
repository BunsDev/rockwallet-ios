// 
//  PaymentCardsWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct PaymentCardsResponseData: ModelResponse {
    struct PaymentInstrument: ModelResponse {
        var type: String
        var id: String?
        var fingerprint: String?
        var expiryMonth: Int?
        var expiryYear: Int?
        var scheme: String?
        var last4: String?
        var accountName: String?
    }
    
    var paymentInstruments: [PaymentInstrument]
}

struct PaymentCard: ItemSelectable, Hashable {
    enum Scheme: String {
        case visa = "VISA"
        case mastercard = "MASTERCARD"
        case none = "card"
    }
    
    enum PaymentType: String {
        case card = "card"
        case bankAccount = "bank_account"
    }
    
    var type: PaymentType
    var id: String
    var fingerprint: String
    var expiryMonth: Int
    var expiryYear: Int
    var scheme: Scheme
    var last4: String
    var image: UIImage?
    var accountName: String
    
    var displayName: String? {
        switch type {
        case .bankAccount:
            return "\(accountName) - \(CardDetailsFormatter.formatBankNumber(last4: last4))"
        default:
            return CardDetailsFormatter.formatNumber(last4: last4)
        }   
    }
    
    var displayImage: ImageViewModel? {
        switch type {
        case .bankAccount:
            return .image(Asset.bank.image) 
        default:
            return .imageName(scheme.rawValue)
        }
    }
}

class PaymentCardsMapper: ModelMapper<PaymentCardsResponseData, [PaymentCard]> {
    override func getModel(from response: PaymentCardsResponseData?) -> [PaymentCard] {
        return response?.paymentInstruments.compactMap {
            return PaymentCard(type: PaymentCard.PaymentType(rawValue: $0.type) ?? .card,
                               id: $0.id ?? "",
                               fingerprint: $0.fingerprint ?? "",
                               expiryMonth: $0.expiryMonth ?? 0,
                               expiryYear: $0.expiryYear ?? 0,
                               scheme: PaymentCard.Scheme(rawValue: $0.scheme ?? "") ?? .none,
                               last4: $0.last4 ?? "",
                               accountName: $0.accountName ?? "")
        } ?? []
    }
}

struct PaymentCardsRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

class PaymentCardsWorker: BaseApiWorker<PaymentCardsMapper> {
    override func getHeaders() -> [String: String] {
        return [
            "Authorization": UserDefaults.kycSessionKeyValue,
            "endpoint-version": "2"
        ].compactMapValues { $0 }
    }
    
    override func getUrl() -> String {
        return ExchangeEndpoints.paymentInstruments.url
    }
}
