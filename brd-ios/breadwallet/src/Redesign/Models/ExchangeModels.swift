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
        case rateAndTimer
        case accountLimits
        case payoutMethod
        case swapCard
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Amounts {
        struct ResponseDisplay {
            var continueEnabled = false
            var amounts: MainSwapViewModel
            var rate: ExchangeRateViewModel?
        }
    }
}

protocol ExchangeResponseDisplays {
    func displayAmount(responseDisplay: ExchangeModels.Amounts.ResponseDisplay)
}
