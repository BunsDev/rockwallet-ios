// 
//  NewDeviceWorker.swift
//  breadwallet
//
//  Created by Rok on 13/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import MobileIntelligence

struct NewDeviceResponseData: ModelResponse {
    var status: String?
    var sessionKey: String?
    var email: String?
}

struct NewDeviceData: Model {
    var sessionKey: String?
    var email: String?
}

class NewDeviceMapper: ModelMapper<NewDeviceResponseData, NewDeviceData> {
    override func getModel(from response: NewDeviceResponseData?) -> NewDeviceData? {
        return .init(sessionKey: response?.sessionKey, email: response?.email)
    }
}

struct NewDeviceRequestData: RequestModelData {
    var nonce = UUID().uuidString
    let token: String?
    
    func getParameters() -> [String: Any] {
        return [
            "nonce": nonce,
            "token": token ?? ""
        ]
    }
}

class NewDeviceWorker: BaseApiWorker<NewDeviceMapper> {
    override func getHeaders() -> [String: String] {
        return UserSignature().getHeaders(nonce: (getParameters()["nonce"] as? String),
                                          token: (getParameters()["token"] as? String))
    }
    
    override func apiCallDidFinish(response: HTTPResponse) {
        super.apiCallDidFinish(response: response)
        guard let result = result,
              let sessionKey = result.sessionKey
        else { return }
        
        var options = UpdateOptions()
        guard sessionKey != options.sessionKey else { return }
        
        options.sessionKey = sessionKey
        MobileIntelligence.updateOptions(options: options)
    }
    
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.newDevice)
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
