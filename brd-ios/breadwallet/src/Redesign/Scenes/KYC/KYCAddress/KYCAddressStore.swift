//
//  KYCAddressStore.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

class KYCAddressStore: NSObject, BaseDataStore, KYCAddressDataStore {
    
    // MARK: - KYCAddressDataStore
    var isPickCountryPressed: Bool = false
    var countries: [Country] = []
    
    // passed
    var itemId: String?
    var name: String?
    var lastName: String?
    var birthdates: String?
    
    // gathered
    var address: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    var countryFullName: String?
    
    var isValid: Bool {
        guard name?.isEmpty == false,
              lastName?.isEmpty == false,
              birthdates?.isEmpty == false,
              address?.isEmpty == false,
              city?.isEmpty == false,
              postalCode?.isEmpty == false,
              country?.isEmpty == false else {
            return false
        }
        
        guard country == C.countryUS else {
            return true
        }
        
        return state?.isEmpty == false
    }
    // MARK: - Aditional helpers
}
