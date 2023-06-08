//
//  AddCardStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 03/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class AddCardStore: NSObject, BaseDataStore, AddCardDataStore {
    // MARK: - AddCardDataStore
    
    var cardNumber: String?
    var cardExpDateString: String?
    var cardExpDateMonth: String?
    var cardExpDateYear: String?
    var cardCVV: String?
    var months: [String] = []
    var years: [String] = []
    
    // MARK: - Additional helpers
    var isValid: Bool {
        return FieldValidator.validate(fields: [cardExpDateYear,
                                                cardExpDateMonth,
                                                cardCVV,
                                                cardNumber])
    }
    
}
