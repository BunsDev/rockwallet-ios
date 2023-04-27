// 
//  PaymailAddressWorker.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 25.4.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct PaymailRequestData: RequestModelData {
    let paymail: String?
    let xpub: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "paymail": paymail,
            "xpub": xpub
        ]
        return params.compactMapValues { $0 }
    }
}

class PaymailAddressWorker: BaseApiWorker<PlainMapper> {
    override func getHeaders() -> [String: String] {
        return UserSignature().getHeaders(nonce: (getParameters()["paymail"] as? String),
                                          token: (getParameters()["xpub"] as? String))
    }
    
    override func getUrl() -> String {
        return PaymailEndpoints.paymail.url
    }

    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }

    override func getMethod() -> HTTPMethod {
        return .post
    }
}
