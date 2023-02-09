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
import MobileIntelligence
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
    
    func showKYCAddress() {
        open(scene: Scenes.KYCAddress)
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
        let controller = KYCBasicViewController()
        controller.coordinator = self
        controller.setBarButtonItem(from: navigationController, to: .right, target: self, action: #selector(popFlow(sender:)))
        navigationController.pushViewController(controller, animated: true)
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
        guard let sessionTokenHash = UserDefaults.sessionTokenHash else { return }
        let options = OptionsBuilder()
            .setClientId(with: E.sardineClientId)
            .setSessionKey(with: sessionTokenHash)
            .setEnvironment(with: E.isSandbox ? Options.ENV_SANDBOX : Options.ENV_PRODUCTION)
            .build()
        MobileIntelligence(withOptions: options)
        
        navigationController.popToRootViewController(animated: false)
        
        VeriffSdk.shared.delegate = self
        VeriffSdk.shared.startAuthentication(sessionUrl: url,
                                             configuration: Presets.veriff,
                                             presentingFrom: navigationController)
    }
    
    func sessionDidEndWithResult(_ result: VeriffSdk.Result) {
        MobileIntelligence.submitData { [weak self] _ in
            guard let self = self else { return }
            
            switch result.status {
            case .done:
                self.handleKYCSessionEnd()
                
            case .error(let error):
                print(error.localizedDescription)
                
                self.open(scene: Scenes.Failure) { vc in
                    vc.failure = .documentVerification
                }
                
            default:
                self.parentCoordinator?.childDidFinish(child: self)
            }
        }
    }
    
    private func handleKYCSessionEnd() {
        UserManager.shared.refresh { [weak self] result in
            switch result {
            case .success(let profile):
                Store.trigger(name: .didApplyKyc)
                
                switch profile?.status {
                case .levelTwo(.levelTwo):
                    self?.open(scene: Scenes.Success) { vc in
                        vc.success = .documentVerification
                    }
                    
                case .levelTwo(.declined):
                    self?.open(scene: Scenes.Failure) { vc in
                        vc.failure = .documentVerification
                    }
                    
                case .levelTwo(.resubmit):
                    self?.open(scene: Scenes.Failure) { vc in
                        vc.failure = .documentVerificationRetry
                    }
                    
                case .levelTwo(.submitted):
                    // If not confirmed/failed yet check again after delay (can take up to 2 mins)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
                        self?.handleKYCSessionEnd()
                    })
                    
                default:
                    break
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                
                self?.open(scene: Scenes.Failure) { vc in
                    vc.failure = .documentVerification
                }
                
            default:
                guard let child = self else { return }
                self?.parentCoordinator?.childDidFinish(child: child)
            }
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
