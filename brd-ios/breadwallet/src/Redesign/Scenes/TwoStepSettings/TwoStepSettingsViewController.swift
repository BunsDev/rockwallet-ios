//
//  TwoStepSettingsViewController.swift
//  breadwallet
//
//  Created by Dino Gacevic on 17/04/2023.
//
//

import UIKit

class TwoStepSettingsViewController: BaseTableViewController<AccountCoordinator,
                                     TwoStepSettingsInteractor,
                                     TwoStepSettingsPresenter,
                                     TwoStepSettingsStore>,
                                     TwoStepSettingsResponseDisplays {
    typealias Models = TwoStepSettingsModels

    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? { return "2FA Settings" }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .description:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .settings:
            cell = self.tableView(tableView, iconTitleSubtitleToggleViewCellForRowAt: indexPath)
            
        default:
            cell = self.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .large, horizontal: .large)
        
        return cell
    }

    // MARK: - User Interaction

    // MARK: - TwoStepSettingsResponseDisplay

    // MARK: - Additional Helpers
}
