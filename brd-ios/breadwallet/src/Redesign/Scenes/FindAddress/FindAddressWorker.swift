// 
//  FindAddressWorker.swift
//  breadwallet
//
//  Created by Dino Gacevic on 14/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct FindAddressRequestModel: RequestModelData {
    let text: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "Text": text
        ]
        
        return params.compactMapValues { $0 }
    }
}

class FindAddressWorker: BaseApiWorker<FindAddressMapper> {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? FindAddressRequestModel),
              let text = urlParams.text else {
            return ""
        }
                
        return APIURLHandler.getUrl(LoquateEndpoints.base, parameters: [E.loqateKey, text])
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func setDecodingStrategy() -> JSONDecoder.KeyDecodingStrategy {
        return .convertFromPascalCase
    }
}

struct FindAddressResponseData: ModelResponse {
    var items: [FindAddressResponseModel]?
    
    struct FindAddressResponseModel: Codable {
        var text: String?
    }
}

struct FindAddress: Model, ItemSelectable {
    var displayName: String? { return text }
    var displayImage: ImageViewModel? { return nil }
    
    var text: String?
}

class FindAddressMapper: ModelMapper<FindAddressResponseData, [FindAddress]> {
    override func getModel(from response: FindAddressResponseData?) -> [FindAddress]? {
        return response?.items?.compactMap { .init(text: $0.text) }
    }
}