//
//  TwoStepAuthenticationViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 27/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class TwoStepAuthenticationViewController: BaseTableViewController<AccountCoordinator,
                                           TwoStepAuthenticationInteractor,
                                           TwoStepAuthenticationPresenter,
                                           TwoStepAuthenticationStore>,
                                           TwoStepAuthenticationResponseDisplays {
    typealias Models = TwoStepAuthenticationModels
    
    override var sceneLeftAlignedTitle: String? { return L10n.TwoStep.mainTitle }
    
    private var didDisplayData = false
    
    // MARK: - Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard didDisplayData else { return }
        interactor?.getData(viewAction: .init())
    }
    
    override func displayData(responseDisplay: FetchModels.Get.ResponseDisplay) {
        super.displayData(responseDisplay: responseDisplay)
        
        didDisplayData = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.TwoFactorAuth())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .instructions:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        case .email, .app, .backupCodes, .settings, .disable:
            cell = self.tableView(tableView, iconTitleSubtitleToggleViewCellForRowAt: indexPath)
            
        case .settingsTitle:
            cell = self.tableView(tableView, titleLabelCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .large, horizontal: .large)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, iconTitleSubtitleToggleViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, iconTitleSubtitleToggleViewCellForRowAt: indexPath)
        
        (cell as? WrapperTableViewCell<IconTitleSubtitleToggleView>)?.wrappedView.didTap = { [weak self] in
            guard let self else { return }
            self.coordinator?.showPinInput(keyStore: self.dataStore?.keyStore, callback: { success in
                if success {
                    switch self.dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
                    case .email:
                        self.coordinator?.showRegistrationConfirmation(isModalDismissable: true, confirmationType: .twoStepEmail)
                        
                    case .app:
                        self.coordinator?.showAuthenticatorApp()
                        
                    default:
                        break
                    }
                } else {
                    
                }
            })
        }
        
        return cell
    }
    
    // MARK: - User Interaction
    
    // MARK: - TwoStepAuthenticationResponseDisplay
    
    // MARK: - Additional Helpers
    
    @objc private func methodsTapped(_ sender: Any) {
        // TODO: Finalize
    }
}
