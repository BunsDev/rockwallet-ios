//
//  RecoveryKeyIntroVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 04/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let RecoveryKeyIntro = RecoveryKeyIntroViewController.self
}

protocol RecoveryKeyIntroViewActions: BaseViewActions, FetchViewActions {
    func toggleTickbox(viewAction: RecoveryKeyIntroModels.Tickbox.ViewAction)
}

protocol RecoveryKeyIntroActionResponses: BaseActionResponses, FetchActionResponses {
    func presentToggleTickbox(actionResponse: RecoveryKeyIntroModels.Tickbox.ActionResponse)
}

protocol RecoveryKeyIntroResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayToggleTickbox(responseDisplay: RecoveryKeyIntroModels.Tickbox.ResponseDisplay)
}

protocol RecoveryKeyIntroDataStore: BaseDataStore, FetchDataStore {
}

protocol RecoveryKeyIntroDataPassing {
    var dataStore: RecoveryKeyIntroDataStore? { get }
}

protocol RecoveryKeyIntroRoutes: CoordinatableRoutes {
}
