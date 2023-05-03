// 
//  AchWorker.swift
//  breadwallet
//
//  Created by Rok on 18/11/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct AchRequestData: RequestModelData {
    var deviceId: String?
    var quoteId: Int?
    var depositQuantity: String
    var withdrawalQuantity: String
    var destination: String?
    var accountId: String?
    var nologCvv: String?
    var useInstantAch: Bool?
    
    func getParameters() -> [String: Any] {
        let params: [String: Any?] = [
            "device_id": deviceId,
            "quote_id": quoteId,
            "deposit_quantity": depositQuantity,
            "withdrawal_quantity": withdrawalQuantity,
            "destination": destination,
            "account_id": accountId,
            "nolog_cvv": nologCvv,
            "use_instant_ach": useInstantAch
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct AchResponseData: ModelResponse {
    var exchangeId: Int?
    var currency: String?
    var amount: String?
    var address: String?
    var status: String?
    var paymentReference: String?
    var redirectUrl: String?
}

struct Ach: Model {
    var exchangeId: String?
    var currency: String?
    var amount: Decimal?
    var address: String?
    var status: AddCard.Status?
    var paymentReference: String?
    var redirectUrl: String?
}

class AchWorkerMapper: ModelMapper<AchResponseData, Swap> {
    override func getModel(from response: AchResponseData?) -> Swap? {
        guard let response = response,
              let amount = Decimal(string: response.amount ?? "")
        else {
            return .init(status: .init(rawValue: response?.status ?? ""),
                         paymentReference: response?.paymentReference,
                         redirectUrl: response?.redirectUrl)
        }
        
        return .init(exchangeId: "\(response.exchangeId ?? 0)",
                     currency: response.currency?.uppercased() ?? "",
                     amount: amount,
                     address: response.address)
    }
}

class AchWorker: BaseApiWorker<AchWorkerMapper> {
    override func getMethod() -> HTTPMethod {
        return .post
    }
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(ExchangeEndpoints.ach)
    }
}
