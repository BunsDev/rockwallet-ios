// 
//  VeriffSessionWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 13/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct VeriffSessionRequestData: RequestModelData {
    var quoteId: String?
    var isBiometric: Bool?
    
    func getParameters() -> [String: Any] {
        return [:]
    }
}

struct VeriffSessionResponseData: ModelResponse {
    var url: String?
}

struct VeriffSession: Model {
    var sessionUrl: String
}

class VeriffSessionWorkerMapper: ModelMapper<VeriffSessionResponseData, VeriffSession> {
    override func getModel(from response: VeriffSessionResponseData?) -> VeriffSession? {
        return .init(sessionUrl: response?.url ?? "")
    }
}

class VeriffSessionWorker: BaseApiWorker<VeriffSessionWorkerMapper> {
    override func getUrl() -> String {
        guard let quoteId = (requestData as? VeriffSessionRequestData)?.quoteId,
              let isBiometric = (requestData as? VeriffSessionRequestData)?.isBiometric else {
            return KYCAuthEndpoints.veriffSession.url
        }
        
        return APIURLHandler.getUrl(KYCAuthEndpoints.veriffBiometricVerificationSession, parameters: [quoteId, isBiometric.description])
    }
}
