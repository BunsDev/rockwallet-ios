// 
//  ExchangeModels.swift
//  breadwallet
//
//  Created by Dino Gacevic on 01/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct ExchangeModels {
    enum Section: Sectionable {
        case segment
        case rateAndTimer
        case accountLimits
        case increaseLimits
        case paymentMethod
        case swapCard
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
}
