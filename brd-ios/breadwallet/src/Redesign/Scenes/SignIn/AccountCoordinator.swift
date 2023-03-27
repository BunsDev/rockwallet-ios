//
//  AccountCoordinator.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class AccountCoordinator: BaseCoordinator, SignInRoutes, SignUpRoutes, ForgotPasswordRoutes, SetPasswordRoutes {
    // MARK: - RegistrationRoutes
    
    override func start() {
        if DynamicLinksManager.shared.code != nil {
            showSetPassword()
            return
        }
        
        if UserManager.shared.profile?.status == .emailPending {
            showRegistrationConfirmation(isModalDismissable: true, confirmationType: .account)
            return
        }
        
        showSignUp()
    }
    
    func showRegistrationConfirmation(isModalDismissable: Bool, confirmationType: RegistrationConfirmationModels.ConfirmationType) {
        open(scene: Scenes.RegistrationConfirmation) { vc in
            vc.dataStore?.confirmationType = confirmationType
            vc.isModalDismissable = isModalDismissable
        }
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
            DynamicLinksManager.shared.dynamicLinkType = nil
        }
    }
    
    func showSignIn() {
        open(scene: Scenes.SignIn)
    }
    
    func showDeleteProfile(with keyMaster: KeyStore) {
        open(scene: Scenes.DeleteProfileInfo) { vc in
            vc.dataStore?.keyMaster = keyMaster
            vc.prepareData()
        }
    }
    
    // MARK: - Aditional helpers
}
