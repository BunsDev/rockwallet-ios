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
                self?.dataStore?.state = profileData?.state?.iso2
                self?.dataStore?.stateFullName = profileData?.state?.name
                self?.dataStore?.postalCode = profileData?.zip
                self?.dataStore?.country = profileData?.country?.iso2
                self?.dataStore?.countryFullName = profileData?.country?.name
                self?.dataStore?.ssn = profileData?.nologSsn
                
                self?.presenter?.presentData(actionResponse: .init(item: self?.dataStore))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func setAddress(viewAction: KYCAddressModels.Address.ViewAction) {
        let requst = RetrievedAddressRequestModel(id: viewAction.address.id)
        RetrieveAddressWorker().execute(requestData: requst) { [weak self] result in
            switch result {
            case .success(let items):
                guard let address = items?.first else { return }
                self?.dataStore?.address = "\(address.street ?? "") \(address.buildingNumber ?? "")"
                self?.dataStore?.city = address.city
                self?.dataStore?.state = address.province
                self?.dataStore?.postalCode = address.postalCode
                self?.pickCountry(viewAction: .init(iso2: address.countryIso2, countryFullName: address.countryName))
                self?.presenter?.presentData(actionResponse: .init(item: self?.dataStore))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func updateForm(viewAction: KYCAddressModels.FormUpdated.ViewAction) {
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
            dataStore?.stateFullName = item?.1
            
        default:
            return
        }
        presenter?.presentForm(actionResponse: .init(isValid: dataStore?.isValid))
    }
    
    func submitInfo(viewAction: KYCAddressModels.Submit.ViewAction) {
        let state = dataStore?.country == C.countryUS ? dataStore?.state : dataStore?.stateFullName
        
        let data = KYCUserInfoRequestData(firstName: dataStore?.firstName ?? "",
                                          lastName: dataStore?.lastName ?? "",
                                          dateOfBirth: dataStore?.birthDateString ?? "",
                                          address: dataStore?.address ?? "",
                                          city: dataStore?.city ?? "",
                                          zip: dataStore?.postalCode ?? "",
                                          country: dataStore?.country ?? "",
                                          state: state,
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
        presenter?.presentExternalKYC(actionResponses: .init())
    }
    
    func showSsnInfo(viewAction: KYCAddressModels.SsnInfo.ViewAction) {
        presenter?.presentSsnInfo(actionResponse: .init())
    }
    
    func validate(viewAction: KYCAddressModels.Validate.ViewAction) {
        presenter?.presentForm(actionResponse: .init(isValid: dataStore?.isValid))
    }

    // MARK: - Aditional helpers
}
