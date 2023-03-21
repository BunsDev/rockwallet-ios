//
//  AccountCoordinator.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit
import PhoneNumberKit

class AccountCoordinator: BaseCoordinator, SignInRoutes, SignUpRoutes, ForgotPasswordRoutes, SetPasswordRoutes {
    // MARK: - RegistrationRoutes
    
    override func start() {
        if DynamicLinksManager.shared.code != nil {
            showSetPassword()
            return
        }
        
        if UserManager.shared.profile?.status == .emailPending {
            showRegistrationConfirmation(isModalDismissable: true)
            return
        }
        
        showSignUp()
    }
    
    func showRegistrationConfirmation(isModalDismissable: Bool) {
        open(scene: Scenes.RegistrationConfirmation) { vc in
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

extension AccountCoordinator: CountryCodePickerDelegate {
    func showAreaCodePicker(model: PhoneNumberViewModel) {
        let phoneNumberKit = PhoneNumberKit()
        let vc = CountryCodePickerViewController(phoneNumberKit: phoneNumberKit)
        vc.delegate = self
        vc
        navigationController.present(vc, animated: true)
    }
    
    func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country) {
        let verifyPhoneNumberVC = navigationController.topViewController as? VerifyPhoneNumberViewController
        
        navigationController.presentedViewController?.dismiss(animated: true)
        
        verifyPhoneNumberVC?.didSelectAreaCode?(country)
    }
}
