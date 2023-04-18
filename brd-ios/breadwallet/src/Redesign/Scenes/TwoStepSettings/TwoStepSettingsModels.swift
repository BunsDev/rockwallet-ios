//
//  TwoStepSettingsModels.swift
//  breadwallet
//
//  Created by Dino Gacevic on 17/04/2023.
//
//

import UIKit

enum TwoStepSettingsModels {
    enum Section: Sectionable {
        case description
        case settings
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
}
