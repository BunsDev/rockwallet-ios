// 
//  SetTwoStepEmailWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 31/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct SetTwoStepEmailRequestData: RequestModelData {
    var updateCode: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "update_code": updateCode
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct SetTwoStepEmailResponseData: ModelResponse {
}

struct SetTwoStepEmail: Model {
}

class SetTwoStepEmailMapper: ModelMapper<SetTwoStepEmailResponseData, SetTwoStepEmail> {
    override func getModel(from response: SetTwoStepEmailResponseData?) -> SetTwoStepEmail? {
        return .init()
    }
}

class SetTwoStepEmailWorker: BaseApiWorker<SetTwoStepEmailMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.email.url
    }
    
    override func getMethod() -> HTTPMethod {
        return .put
    }
}
