// 
//  SetPasswordWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 17/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct SetPasswordRequestData: RequestModelData {
    let guid: String?
    let code: String?
    let password: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "guid": guid,
            "code": code,
            "password": password
        ]
        return params.compactMapValues { $0 }
    }
}

class SetPasswordWorker: BaseApiWorker<PlainMapper> {
    override func getUrl() -> String {
        return WalletEndpoints.set.url
    }

    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }

    override func getMethod() -> HTTPMethod {
        return .post
    }
}
