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
    
    var countries: [Place] = []
    
    var itemId: String?
    var firstName: String?
    var lastName: String?
    var birthDateString: String?
    var address: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    var countryFullName: String?
    var ssn: String?
    
    var isValid: Bool {
        guard address?.isEmpty == false,
              city?.isEmpty == false,
              postalCode?.isEmpty == false,
              country?.isEmpty == false else {
            return false
        }
        
        guard country == C.countryUS else {
            return true
        }
        
        guard state?.isEmpty == false else {
            return false
        }
        return true
    }
    
    // MARK: - Aditional helpers
}
