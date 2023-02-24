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
    override func start() {
        start(flow: nil)
    }
    
    func start(flow: ProfileModels.ExchangeFlow?) {
        if let flow = flow {
            open(scene: Scenes.VerifyAccount) { vc in
                vc.flow = flow
            }
            
            return
        }
        
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
    
    func showStateSelector(states: [Place], selected: ((Place?) -> Void)?) {
        openModally(coordinator: ItemSelectionCoordinator.self,
                    scene: Scenes.ItemSelection,
                    presentationStyle: .formSheet) { vc in
            vc?.dataStore?.items = states
            vc?.dataStore?.sceneTitle = L10n.Account.selectState
            vc?.itemSelected = { item in
                selected?(item as? Place)
            }
            vc?.prepareData()
        }
    }
    
    func showKYCLevelOne() {
        open(scene: Scenes.KYCBasic)
    }
    
    func showFindAddress(completion: ((ResidentialAddress) -> Void)?) {
        openModally(coordinator: ItemSelectionCoordinator.self,
                    scene: Scenes.FindAddress,
                    presentationStyle: .formSheet) { vc in
            vc?.callback = { address in
                completion?(address)
            }
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

extension BaseCoordinator: VeriffSdkDelegate {
    func showExternalKYC() {
        navigationController.popToRootViewController(animated: false)
        
        UserManager.shared.getVeriffSessionUrl { [weak self] result in
            switch result {
            case .success(let data):
                guard let navigationController = self?.navigationController else { return }
                
                VeriffSdk.shared.delegate = self
                VeriffSdk.shared.startAuthentication(sessionUrl: data?.sessionUrl ?? "",
                                                     configuration: Presets.veriff,
                                                     presentingFrom: navigationController)
                
            default:
                break
            }
        }
    }
    
    func sessionDidEndWithResult(_ result: VeriffSdk.Result) {
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
            dismissFlow()
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
