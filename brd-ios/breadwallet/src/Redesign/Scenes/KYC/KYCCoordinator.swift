// 
//  KYCCoordinator.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import AVFoundation
import UIKit
import Veriff

class KYCCoordinator: BaseCoordinator,
                      KYCBasicRoutes,
                      CountriesAndStatesRoutes,
                      KYCAddressRoutes,
                      AssetSelectionDisplayable {
    var flow: ProfileModels.ExchangeFlow?
    
    override func start() {
        switch UserManager.shared.profile?.status {
        case .emailPending:
            let coordinator = AccountCoordinator(navigationController: navigationController)
            coordinator.start()
            coordinator.parentCoordinator = self
            childCoordinators.append(coordinator)
            
        default:
            showKYCLevelOne()
        }
    }
    
    func showKYCAddress(firstName: String?, lastName: String?, birthDate: String?) {
        open(scene: Scenes.KYCAddress) { vc in
            vc.dataStore?.firstName = firstName
            vc.dataStore?.lastName = lastName
            vc.dataStore?.birthDateString = birthDate
        }
    }
    
    func showCountrySelector(countries: [Country], selected: ((Country?) -> Void)?) {
        openModally(coordinator: ItemSelectionCoordinator.self,
                    scene: Scenes.ItemSelection,
                    presentationStyle: .formSheet) { vc in
            vc?.dataStore?.items = countries
            vc?.dataStore?.sceneTitle = L10n.Account.selectCountry
            vc?.itemSelected = { item in
                selected?(item as? Country)
            }
            vc?.prepareData()
        }
    }
    
    func showStateSelector(states: [USState], selected: ((USState?) -> Void)?) {
        openModally(coordinator: ItemSelectionCoordinator.self,
                    scene: Scenes.ItemSelection,
                    presentationStyle: .formSheet) { vc in
            vc?.dataStore?.items = states
            vc?.dataStore?.sceneTitle = L10n.Account.selectState
            vc?.itemSelected = { item in
                selected?(item as? USState)
            }
            vc?.prepareData()
        }
    }
    
    func showKYCLevelOne() {
        open(scene: Scenes.KYCBasic, presentationStyle: .fullScreen) { vc in
            vc.setBarButtonItem(from: self.navigationController, to: .right, target: self, action: #selector(self.popFlow(sender:)))
        }
    }
    
    // MARK: - Aditional helpers
    
    @objc func popFlow(sender: UIBarButtonItem) {
        if navigationController.children.count == 1 {
            dismissFlow()
        }
        
        navigationController.popToRootViewController(animated: true)
    }
}

extension KYCCoordinator: VeriffSdkDelegate {
    func showExternalKYC(url: String) {
        turnOnSardineMobileIntelligence()
        
        navigationController.popToRootViewController(animated: false)
        
        VeriffSdk.shared.delegate = self
        VeriffSdk.shared.startAuthentication(sessionUrl: url,
                                             configuration: Presets.veriff,
                                             presentingFrom: navigationController)
    }
    
    func sessionDidEndWithResult(_ result: VeriffSdk.Result) {
        submitSardineMobileIntelligence()
        
        switch result.status {
        case .done:
            open(scene: Scenes.verificationInProgress) { vc in
                vc.navigationItem.hidesBackButton = true
            }
        case .error(let error):
            print(error.localizedDescription)
            
            open(scene: Scenes.Failure) { vc in
                vc.failure = .documentVerification
            }
            
        default:
            parentCoordinator?.childDidFinish(child: self)
        }
    }
}

extension KYCCoordinator {
    func showDatePicker(model: DateViewModel) {
        guard let viewController = navigationController.children.last(where: { $0 is KYCBasicViewController }) as? KYCBasicViewController else { return }
        DatePickerViewController.show(on: viewController,
                                      sourceView: viewController.view,
                                      title: nil,
                                      date: model.date ?? Date(),
                                      minimumDate: Calendar.current.date(byAdding: .year, value: -120, to: Date()),
                                      maximumDate: Date()) { date in
            viewController.interactor?.birthDateSet(viewAction: .init(date: date))
        }
    }
}
