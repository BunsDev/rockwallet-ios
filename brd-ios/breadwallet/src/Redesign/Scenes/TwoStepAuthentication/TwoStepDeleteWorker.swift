// 
//  TwoStepDeleteWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 19/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct TwoStepDeleteRequestData: RequestModelData {
    var updateCode: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "update_code": updateCode
        ]
        
        return params.compactMapValues { $0 }
    }
}

struct TwoStepDeleteResponseData: ModelResponse {
}

struct TwoStepDelete: Model {
    
}

class TwoStepDeleteMapper: ModelMapper<TwoStepDeleteResponseData, TwoStepDelete> {
    override func getModel(from response: TwoStepDeleteResponseData?) -> TwoStepDelete? {
        return .init()
    }
}

class TwoStepDeleteWorker: BaseApiWorker<TwoStepDeleteMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.delete.url
    }
    
    override func getMethod() -> HTTPMethod {
        return .delete
    }
}
