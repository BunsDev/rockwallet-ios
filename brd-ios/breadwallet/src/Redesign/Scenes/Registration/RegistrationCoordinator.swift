//
//  RegistrationCoordinator.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationCoordinator: BaseCoordinator, RegistrationRoutes {
    // MARK: - RegistrationRoutes
    
    override func start() {
        if UserDefaults.kycSessionKeyValue == nil {
            return open(scene: Scenes.Registration) { vc in
                vc.navigationItem.hidesBackButton = true
            }
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
    
    func showChangeEmail() {
        open(scene: Scenes.Registration) { vc in
            vc.dataStore?.type = .resend
            vc.prepareData()
        }
    }
    
    // MARK: - Aditional helpers
}
