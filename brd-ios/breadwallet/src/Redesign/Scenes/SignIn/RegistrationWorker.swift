// 
//  RegistrationWorker.swift
//  breadwallet
//
//  Created by Rok on 01/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class RegistrationMapper: ModelMapper<RegistrationResponseData, RegistrationData> {
    override func getModel(from response: RegistrationResponseData?) -> RegistrationData? {
        guard let key = response?.sessionKey else {
            return nil
        }
        return .init(sessionKey: key)
    }
}

struct RegistrationResponseData: ModelResponse {
    var data: [String: String]?
    var sessionKey: String? {
        return data?["sessionKey"]
    }
}

struct RegistrationData: Model {
    var sessionKey: String?
}

struct RegistrationRequestData: RequestModelData {
    let email: String?
    let password: String?
    let token: String?
    let subscribe: Bool?
    
    enum AccountHandling {
        case register, login
    }
    
    let accountHandling: AccountHandling
    
    func getParameters() -> [String: Any] {
        let params: [String: Any?] = [
            "email": email,
            "password": password,
            "token": token,
            "subscribe": subscribe
        ]
        
        return params.compactMapValues { $0 }
    }
}

class RegistrationWorker: BaseApiWorker<RegistrationMapper> {
    override func getHeaders() -> [String: String] {
        return UserSignature().getHeaders(nonce: (getParameters()["email"] as? String),
                                          token: (getParameters()["token"] as? String))
    }
    
    override func getUrl() -> String {
        let accountHandling = (requestData as? RegistrationRequestData)?.accountHandling
        
        switch accountHandling {
        case .login:
            return APIURLHandler.getUrl(WalletEndpoints.login)
            
        case .register:
            return APIURLHandler.getUrl(WalletEndpoints.register)
            
        default:
            return ""
        }
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
