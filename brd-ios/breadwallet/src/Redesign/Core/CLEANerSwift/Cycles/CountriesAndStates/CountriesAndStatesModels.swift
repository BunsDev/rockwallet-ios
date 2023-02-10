// 
//  CountriesAndStatesModels.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum CountriesAndStatesModels {
    struct SelectCountry {
        struct ViewAction {
            var code: String?
            var countryFullName: String?
        }
        
        struct ActionResponse {
            var countries: [Place]?
        }
        
        struct ResponseDisplay {
            var countries: [Place]
        }
    }
}
