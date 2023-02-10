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
                self?.dataStore?.ssn = profileData?.nologSsn
                
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
            
        case .postalCode:
            dataStore?.postalCode = viewAction.value as? String
            
        case .ssn:
            dataStore?.ssn = viewAction.value as? String
            
        case .cityAndState:
            let item = viewAction.value as? (String?, String?)
            dataStore?.city = item?.0
            dataStore?.state = item?.1
            
        default:
            return
        }
        presenter?.presentForm(actionResponse: .init(isValid: dataStore?.isValid))
    }
    
    func submitInfo(viewAction: KYCAddressModels.Submit.ViewAction) {
        let data = KYCUserInfoRequestData(firstName: dataStore?.firstName ?? "",
                                          lastName: dataStore?.lastName ?? "",
                                          dateOfBirth: dataStore?.birthDateString ?? "",
                                          address: dataStore?.address ?? "",
                                          city: dataStore?.city ?? "",
                                          zip: dataStore?.postalCode ?? "",
                                          country: dataStore?.country ?? "",
                                          state: dataStore?.state,
                                          nologSSN: dataStore?.ssn)
        
        KYCSubmitInfoWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                self?.startExternalKYC(viewAction: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
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
    
    func showSsnInfo(viewAction: KYCAddressModels.SsnInfo.ViewAction) {
        presenter?.presentSsnInfo(actionResponse: .init())
    }

    // MARK: - Aditional helpers
}
