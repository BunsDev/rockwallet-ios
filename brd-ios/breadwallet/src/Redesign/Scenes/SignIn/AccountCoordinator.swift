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
            showRegistrationConfirmation()
            return
        }
        
        showSignUp()
    }
    
    func showRegistrationConfirmation() {
        open(scene: Scenes.RegistrationConfirmation) { vc in
            vc.prepareData()
        }
    }
    
    func showChangeEmail() {
        open(scene: Scenes.SignUp) { vc in
            vc.prepareData()
        }
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
        }
    }
    
    func showSignIn() {
        open(scene: Scenes.SignIn)
    }
    
    // MARK: - Aditional helpers
}
