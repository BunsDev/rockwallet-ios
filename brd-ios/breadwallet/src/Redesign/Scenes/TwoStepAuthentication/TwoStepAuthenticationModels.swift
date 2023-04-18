//
//  SwapCurrencyView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 27/03/2023.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum TwoStepAuthenticationModels {
    typealias Item = TwoStepSettingsResponseData.TwoStepType?
    
    enum Section: Sectionable {
        case instructions
        case email
        case app
        case divider
        case settingsTitle
        case backupCodes
        case settings
        case disable
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
}
