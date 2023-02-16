// 
//  RetrieveAddressWorker.swift
//  breadwallet
//
//  Created by Dino Gacevic on 15/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct RetrieveAddressRequestModel: RequestModelData {
    let id: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "Id": id
        ]
        
        return params.compactMapValues { $0 }
    }
}

class RetrieveAddressWorker: BaseApiWorker<RetrieveAddressMapper> {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? RetrieveAddressRequestModel),
              let id = urlParams.id else {
            return ""
        }
                
        return APIURLHandler.getUrl(LoquateEndpoints.retrieve, parameters: [E.loqateKey, id])
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func setDecodingStrategy() -> JSONDecoder.KeyDecodingStrategy {
        return .convertFromPascalCase
    }
}

struct RetrieveAddressResponseModel: Codable {
    var id: String?
    var street: String?
    var buildingNumber: String?
    var city: String?
    var postalCode: String?
    var countryName: String?
    var countryIso2: String?
    var province: String?
}

struct RetrieveAddressResponseData: ModelResponse {
    var items: [RetrieveAddressResponseModel]?
}

struct RetrievedAddress: Model {
    var id: String?
    var street: String?
    var buildingNumber: String?
    var city: String?
    var postalCode: String?
    var countryName: String?
    var countryIso2: String?
    var province: String?
    
    init(with response: RetrieveAddressResponseModel?) {
        id = response?.id
        street = response?.street
        buildingNumber = response?.buildingNumber
        city = response?.city
        postalCode = response?.postalCode
        countryName = response?.countryName
        countryIso2 = response?.countryIso2
        province = response?.province
    }
}

class RetrieveAddressMapper: ModelMapper<RetrieveAddressResponseData, [RetrievedAddress]> {
    override func getModel(from response: RetrieveAddressResponseData?) -> [RetrievedAddress]? {
        return response?.items?.compactMap { .init(with: $0) }
    }
}
