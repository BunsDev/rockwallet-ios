//
//  KYCAddressInteractor.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

class KYCAddressInteractor: NSObject, Interactor, KYCAddressViewActions {
    typealias Models = KYCAddressModels

    var presenter: KYCAddressPresenter?
    var dataStore: KYCAddressStore?
    
    // MARK: - KYCAddressViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        UserInformationWorker().execute { [weak self] result in
            switch result {
            case .success(let profileData):
                self?.dataStore?.address = profileData?.address
                self?.dataStore?.city = profileData?.city
                self?.dataStore?.state = profileData?.state
                self?.dataStore?.postalCode = profileData?.zip
                self?.dataStore?.country = profileData?.country
                self?.dataStore?.countryFullName = profileData?.country
                
                self?.presenter?.presentData(actionResponse: .init(item: self?.dataStore))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func formUpdated(viewAction: KYCAddressModels.FormUpdated.ViewAction) {
        switch viewAction.section as? Models.Section {
        case .address:
            dataStore?.address = viewAction.value as? String
            
        case .stateProvince:
            dataStore?.state = viewAction.value as? String
            
        case .cityAndZipPostal:
            let item = viewAction.value as? (String?, String?)
            dataStore?.city = item?.0
            dataStore?.postalCode = item?.1
            
        default:
            return
        }
        presenter?.presentForm(actionResponse: .init(isValid: dataStore?.isValid))
    }
    
    func startExternalKYC(viewAction: KYCAddressModels.ExternalKYC.ViewAction) {
        VeriffSessionWorker().execute { [weak self] result in
            switch result {
            case .success(let data):
                self?.presenter?.presentExternalKYC(actionResponses: .init(address: data?.sessionUrl))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }

    // MARK: - Aditional helpers
}
