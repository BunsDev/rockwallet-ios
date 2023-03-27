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
    
    // MARK: - Overrides
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .instructions:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        case .methods:
            cell = self.tableView(tableView, iconTitleSubtitleToggleViewCellForRowAt: indexPath)
            
        case .additionalMethods:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
            // TODO: This and similar cases should be cleaned up and unified.
            let wrappedCell = cell as? WrapperTableViewCell<FELabel>
            wrappedCell?.isUserInteractionEnabled = true
            wrappedCell?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(methodsTapped(_:))))
            
        case .settingsTitle:
            cell =  self.tableView(tableView, titleLabelCellForRowAt: indexPath)
            
        case .settings:
            cell = self.tableView(tableView, iconTitleSubtitleToggleViewCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .large, horizontal: .large)
        
        return cell
    }
    
    // MARK: - User Interaction
    
    // MARK: - TwoStepAuthenticationResponseDisplay
    
    // MARK: - Additional Helpers
    
    @objc private func methodsTapped(_ sender: Any) {
        // TODO: Finalize
    }
}
