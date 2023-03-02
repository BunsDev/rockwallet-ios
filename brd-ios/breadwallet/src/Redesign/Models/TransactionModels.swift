// 
//  TransactionModels.swift
//  breadwallet
//
//  Created by Dino Gacevic on 01/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct TransactionModels {
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
            var rate: ExchangeRateViewModel? = nil
        }
    }
}

protocol TransactionResponseDisplays {
    func displayAmount(responseDisplay: TransactionModels.Amounts.ResponseDisplay)
}
