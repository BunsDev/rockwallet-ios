//
//  KYCAddressVIP.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

extension Scenes {
    static let KYCAddress = KYCAddressViewController.self
}

protocol KYCAddressViewActions: BaseViewActions, CountriesAndStatesViewActions {
    func formUpdated(viewAction: KYCAddressModels.FormUpdated.ViewAction)
}

protocol KYCAddressActionResponses: BaseActionResponses, CountriesAndStatesActionResponses {
}

protocol KYCAddressResponseDisplays: AnyObject, BaseResponseDisplays, CountriesAndStatesResponseDisplays {
}

protocol KYCAddressDataStore: BaseDataStore, CountriesAndStatesDataStore {
    // passed
    var name: String? { get set }
    var lastName: String? { get set }
    var birthdates: String? { get set }
    // gathered
    var address: String? { get set }
    var city: String? { get set }
    var state: String? { get set }
    var postalCode: String? { get set }
    var country: String? { get set }
    var countryFullName: String? { get set }
    
    var isValid: Bool { get }
}

protocol KYCAddressDataPassing {
    var dataStore: KYCAddressDataStore? { get }
}

protocol KYCAddressRoutes: CoordinatableRoutes {
}
