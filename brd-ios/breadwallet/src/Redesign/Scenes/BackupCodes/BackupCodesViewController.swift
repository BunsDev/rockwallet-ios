//
//  BackupCodesViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 23.3.23.
//
//

import UIKit

class BackupCodesViewController: BaseTableViewController<BackupCodesCoordinator,
                                 BackupCodesInteractor,
                                 BackupCodesPresenter,
                                 BackupCodesStore>,
                                 BackupCodesResponseDisplays {
    typealias Models = BackupCodesModels

    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? {
        return "Backup codes"
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: L10n.Onboarding.next,
                                         enabled: true,
                                         callback: { [weak self] in
            self?.buttonTapped()
        }))
        
        guard let config = continueButton.config, let model = continueButton.viewModel else { return }
        verticalButtons.wrappedView.configure(with: .init(buttons: [config]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [model]))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .instructions, .description:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
        
        case .getNewCodes:
            cell = self.tableView(tableView, multipleButtonsCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .large, horizontal: .large)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, multipleButtonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, multipleButtonsCellForRowAt: indexPath)
        
        guard let cell = cell as? WrapperTableViewCell<MultipleButtonsView> else {
            return cell
        }
        
        cell.setup { view in
            view.configure(with: .init(buttons: [Presets.Button.noBorders],
                                       axis: .horizontal))
            
            view.callbacks = [
                getCodesTapped
            ]
        }
        
        return cell
    }

    // MARK: - User Interaction
    
    private func getCodesTapped() {
        
    }

    // MARK: - BackupCodesResponseDisplay

    // MARK: - Additional Helpers
}
