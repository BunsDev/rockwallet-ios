//
//  RegistrationConfirmationInteractor.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationConfirmationInteractor: NSObject, Interactor, RegistrationConfirmationViewActions {
    typealias Models = RegistrationConfirmationModels

    var presenter: RegistrationConfirmationPresenter?
    var dataStore: RegistrationConfirmationStore?

    // MARK: - RegistrationConfirmationViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard let confirmationType = dataStore?.confirmationType else { return }
        
        presenter?.presentData(actionResponse: .init(item: confirmationType))
        
        switch dataStore?.confirmationType {
        case .twoStepEmail, .twoStepEmailLogin, .disable:
            resend(viewAction: .init())
            
        default:
            break
        }
        
        guard E.isDevelopment else { return }
        ConfirmationCodesWorker().execute(requestData: ConfirmationCodesRequestData()) { _ in }
    }
    
    func validate(viewAction: RegistrationConfirmationModels.Validate.ViewAction) {
        let code = viewAction.code ?? ""
        
        dataStore?.code = code
        
        if code.count == CodeInputView.numberOfFields {
            confirm(viewAction: .init())
        }
    }
    
    func confirm(viewAction: RegistrationConfirmationModels.Confirm.ViewAction) {
        switch dataStore?.confirmationType {
        case .account:
            executeRegistrationConfirmation()
            
        case .twoStepEmail, .acountTwoStepEmailSettings:
            executeSetTwoStepEmail()
            
        case .twoStepApp, .acountTwoStepAppSettings, .enterAppBackupCode:
            executeSetTwoStepApp()
        
        case .twoStepEmailLogin, .twoStepAppLogin:
            executeLogin()
            
        case .disable:
            executeDisable()
            
        default:
            break
        }
    }
    
    func resend(viewAction: RegistrationConfirmationModels.Resend.ViewAction) {
        switch dataStore?.confirmationType {
        case .twoStepEmailLogin, .twoStepAppLogin:
            RequestTwoStepCodeWorker().execute(requestData: RequestTwoStepCodeRequestData()) { [weak self] result in
                switch result {
                case .success:
                    self?.presenter?.presentResend(actionResponse: .init())
                    
                case .failure(let error):
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                }
            }
            
        case .twoStepEmail, .twoStepApp, .acountTwoStepEmailSettings, .acountTwoStepAppSettings, .disable:
            TwoStepChangeWorker().execute(requestData: TwoStepChangeRequestData()) { [weak self] result in
                switch result {
                case .success:
                    self?.presenter?.presentResend(actionResponse: .init())
                    
                case .failure(let error):
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                }
            }
            
        case .account:
            ResendConfirmationWorker().execute { [weak self] result in
                switch result {
                case .success:
                    self?.presenter?.presentResend(actionResponse: .init())
                    
                case .failure(let error):
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                }
            }
            
        default:
            break
        }
    }

    // MARK: - Aditional helpers
    
    private func executeLogin() {
        dataStore?.registrationRequestData?.secondFactorCode = dataStore?.code
        
        guard let registrationRequestData = dataStore?.registrationRequestData else { return }
        
        RegistrationWorker().execute(requestData: registrationRequestData) { [weak self] result in
            switch result {
            case .success(let data):
                guard let sessionKey = data?.sessionKey, let sessionKeyHash = data?.sessionKeyHash else { return }
                
                UserManager.shared.setUserCredentials(email: registrationRequestData.email ?? "", sessionToken: sessionKey, sessionTokenHash: sessionKeyHash)
                
                UserManager.shared.refresh { _ in
                    self?.presenter?.presentConfirm(actionResponse: .init())
                }
                
            case .failure(let error):
                guard let error = (error as? NetworkingError) else {
                    self?.presenter?.presentError(actionResponse: .init(error: error))
                    return
                }
                
                self?.presenter?.presentNextFailure(actionResponse: .init(reason: error,
                                                                          registrationRequestData: registrationRequestData))
            }
        }
    }
    
    private func executeSetTwoStepPhone() {
        let data = SetTwoStepPhoneCodeRequestData(code: dataStore?.code)
        SetTwoStepPhoneCodeWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                UserManager.shared.refresh { _ in
                    self?.presenter?.presentConfirm(actionResponse: .init())
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    private func executeSetTwoStepApp() {
        let data = SetTwoStepAppCodeRequestData(code: dataStore?.code)
        SetTwoStepAppCodeWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                UserManager.shared.refresh { _ in
                    self?.presenter?.presentConfirm(actionResponse: .init())
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    private func executeSetTwoStepEmail() {
        let data = SetTwoStepAuthRequestData(type: .email, updateCode: dataStore?.code)
        SetTwoStepAuthWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                UserManager.shared.refresh { _ in
                    self?.presenter?.presentConfirm(actionResponse: .init())
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    private func executeRegistrationConfirmation() {
        let data = RegistrationConfirmationRequestData(code: dataStore?.code)
        RegistrationConfirmationWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                UserManager.shared.refresh { _ in
                    self?.presenter?.presentConfirm(actionResponse: .init())
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    private func executeDisable() {
        let data = TwoStepDeleteRequestData(updateCode: dataStore?.code)
        TwoStepDeleteWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                UserManager.shared.refresh { _ in
                    self?.presenter?.presentConfirm(actionResponse: .init())
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
}
