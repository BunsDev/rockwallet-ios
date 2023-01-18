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
        if UserDefaults.email == nil {
            showSignUp()
        } else {
            showRegistrationConfirmation()
        }
    }
    
    func showRegistrationConfirmation() {
        open(scene: Scenes.RegistrationConfirmation) { vc in
            vc.navigationItem.hidesBackButton = true
            vc.prepareData()
        }
    }
    
    // TODO: Should this be removed?
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
    
    func showSignIn() {
        open(scene: Scenes.SignIn)
    }
    
    // MARK: - Aditional helpers
}
