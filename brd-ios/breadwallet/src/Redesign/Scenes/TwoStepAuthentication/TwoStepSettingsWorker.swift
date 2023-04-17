// 
//  TwoStepSettingsWorkers.swift
//  breadwallet
//
//  Created by Kanan Mamedoff on 24/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct TwoStepSettingsRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

struct TwoStepSettingsResponseData: ModelResponse {
}

struct TwoStepSettings: Model {
}

class TwoStepSettingsMapper: ModelMapper<TwoStepSettingsResponseData, TwoStepSettings> {
    override func getModel(from response: TwoStepSettingsResponseData?) -> TwoStepSettings? {
        return .init()
    }
}

class TwoStepSettingsWorker: BaseApiWorker<TwoStepSettingsMapper> {
    override func getUrl() -> String {
        return TwoStepEndpoints.settings.url
    }
}
