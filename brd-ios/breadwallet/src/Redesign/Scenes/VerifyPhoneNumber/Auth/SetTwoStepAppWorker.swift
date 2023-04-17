// 
//  SetTwoStepAppWorker.swift
//  breadwallet
//
//  Created by Kanan Mamedoff on 17/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct SetTwoStepAppRequestData: RequestModelData {
    var updateCode: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "update_code": updateCode
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct SetTwoStepAppResponseData: ModelResponse {
}

struct SetTwoStepApp: Model {
}

class SetTwoStepAppMapper: ModelMapper<SetTwoStepAppResponseData, SetTwoStepApp> {
    override func getModel(from response: SetTwoStepAppResponseData?) -> SetTwoStepApp? {
        return .init() // Should return something?!
    }
}

class SetTwoStepAppWorker: BaseApiWorker<SetTwoStepAppMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.totp.url
    }
    
    override func getMethod() -> HTTPMethod {
        return .put
    }
}
