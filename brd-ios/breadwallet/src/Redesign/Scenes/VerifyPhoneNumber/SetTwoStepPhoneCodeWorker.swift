// 
//  SetTwoStepPhoneCodeCodeWorker.swift
//  breadwallet
//
//  Created by Kanan Mamedoff on 31/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct SetTwoStepPhoneCodeRequestData: RequestModelData {
    var code: String?
    
    func getParameters() -> [String: Any] {
        return ["code": code ?? ""]
    }
}

struct SetTwoStepPhoneCodeResponseData: ModelResponse {
}

struct SetTwoStepPhoneCode: Model {
}

class SetTwoStepPhoneCodeMapper: ModelMapper<SetTwoStepPhoneCodeResponseData, SetTwoStepPhoneCode> {
    override func getModel(from response: SetTwoStepPhoneCodeResponseData?) -> SetTwoStepPhoneCode? {
        return .init()
    }
}

class SetTwoStepPhoneCodeWorker: BaseApiWorker<SetTwoStepPhoneCodeMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.phoneConfirm.url
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}

struct ConfirmationCodesRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

class ConfirmationCodesWorker: BaseApiWorker<PlainMapper> {
    override func getUrl() -> String {
        return KYCAuthEndpoints.confirmationCodes.url
    }
}
