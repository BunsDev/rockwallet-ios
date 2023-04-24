//
//  AccountCoordinator.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class AccountCoordinator: ExchangeCoordinator, SignInRoutes, SignUpRoutes, ForgotPasswordRoutes, SetPasswordRoutes {
    // MARK: - RegistrationRoutes
    
    override func start() {
        if DynamicLinksManager.shared.code != nil {
            showSetPassword()
        } else if UserManager.shared.profile?.status == .emailPending {
            showRegistrationConfirmation(isModalDismissable: true, confirmationType: .account)
        } else {
            showSignUp()
        }
    }
    
    func showRegistrationConfirmation(isModalDismissable: Bool,
                                      confirmationType: RegistrationConfirmationModels.ConfirmationType,
                                      registrationRequestData: RegistrationRequestData? = nil,
                                      setPasswordRequestData: SetPasswordRequestData? = nil) {
        open(scene: Scenes.RegistrationConfirmation) { vc in
            vc.dataStore?.confirmationType = confirmationType
            vc.dataStore?.registrationRequestData = registrationRequestData
            vc.dataStore?.setPasswordRequestData = setPasswordRequestData
            vc.isModalDismissable = isModalDismissable
        }
    }
    
    func showVerifyPhoneNumber() {
        open(scene: Scenes.VerifyPhoneNumber)
    }
    
    func showAuthenticatorApp() {
        open(scene: Scenes.AuthenticatorApp)
    }
    
    func showBackupCodes() {
        open(scene: Scenes.BackupCodes)
    }
    
    func showTwoStepSettings() {
        open(scene: Scenes.TwoStepSettings)
    }
    
    func showChangeEmail() {
        open(scene: Scenes.SignUp)
    }
    
    func showForgotPassword() {
        open(scene: Scenes.ForgotPassword)
    }
    
    func showSignUp() {
        open(scene: Scenes.SignUp) { vc in
            vc.navigationItem.hidesBackButton = true
        }
    }
    
    func showSetPassword() {
        open(scene: Scenes.SetPassword) { vc in
            vc.navigationItem.hidesBackButton = true
            
            vc.dataStore?.code = DynamicLinksManager.shared.code
            
            DynamicLinksManager.shared.code = nil
        }
    }
    
    func showSignIn() {
        open(scene: Scenes.SignIn)
    }
    
    func showDeleteProfile(with keyMaster: KeyStore) {
        open(scene: Scenes.DeleteProfileInfo) { vc in
            vc.dataStore?.keyMaster = keyMaster
        }
    }
    
    func showAccountBlocked() {
        open(scene: Scenes.AccountBlocked) { vc in
            vc.navigationItem.hidesBackButton = true
            
            vc.didTapMainButton = { [weak self] in
                self?.dismissFlow()
            }
            
            vc.didTapSecondayButton = { [weak self] in
                self?.showSupport()
            }
        }
    }
    
    func showTwoStepErrorFlow(reason: NetworkingError,
                              registrationRequestData: RegistrationRequestData?,
                              setPasswordRequestData: SetPasswordRequestData?) {
        if reason == .twoStepAppRequired {
            let type: RegistrationConfirmationModels.ConfirmationType = registrationRequestData == nil ? .twoStepAppResetPassword : .twoStepAppLogin
            
            showRegistrationConfirmation(isModalDismissable: true,
                                         confirmationType: type,
                                         registrationRequestData: registrationRequestData,
                                         setPasswordRequestData: setPasswordRequestData)
        } else if reason == .twoStepEmailRequired {
            let type: RegistrationConfirmationModels.ConfirmationType = registrationRequestData == nil ? .twoStepEmailResetPassword : .twoStepEmailLogin
            
            showRegistrationConfirmation(isModalDismissable: true,
                                         confirmationType: type,
                                         registrationRequestData: registrationRequestData,
                                         setPasswordRequestData: setPasswordRequestData)
        } else if reason == .twoStepBlockedAccount || reason == .twoStepInvalidCodeBlockedAccount {
            showAccountBlocked()
        }
    }
    
    func showKYCLevelOne() {
        open(coordinator: KYCCoordinator.self, scene: Scenes.KYCBasic)
    }
    
    // MARK: - Aditional helpers
}
