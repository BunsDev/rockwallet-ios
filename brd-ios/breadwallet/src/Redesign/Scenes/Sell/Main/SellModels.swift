//
//  SellModels.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

enum SellModels {
    enum Sections: Sectionable {
        case rateAndTimer
        case accountLimits
        case swapCard
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
}
