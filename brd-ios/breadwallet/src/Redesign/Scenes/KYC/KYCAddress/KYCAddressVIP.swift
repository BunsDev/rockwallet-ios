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
    func startExternalKYC(viewAction: KYCAddressModels.ExternalKYC.ViewAction)
}

protocol KYCAddressActionResponses: BaseActionResponses, CountriesAndStatesActionResponses {
    func presentForm(actionResponse: KYCAddressModels.FormUpdated.ActionResponse)
    func presentExternalKYC(actionResponses: KYCAddressModels.ExternalKYC.ActionResponse)
}

protocol KYCAddressResponseDisplays: AnyObject, BaseResponseDisplays, CountriesAndStatesResponseDisplays {
    func displayForm(responseDisplay: KYCAddressModels.FormUpdated.ResponseDisplay)
    func displayExternalKYC(responseDisplay: KYCAddressModels.ExternalKYC.ResponseDisplay)
}

protocol KYCAddressDataStore: BaseDataStore, CountriesAndStatesDataStore {
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
    func showExternalKYC(url: String)
}
