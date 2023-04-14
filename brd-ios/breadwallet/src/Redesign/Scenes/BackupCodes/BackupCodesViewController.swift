//
//  BackupCodesViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 23.3.23.
//
//

import UIKit

class BackupCodesViewController: BaseTableViewController<AccountCoordinator,
                                 BackupCodesInteractor,
                                 BackupCodesPresenter,
                                 BackupCodesStore>,
                                 BackupCodesResponseDisplays {
    typealias Models = BackupCodesModels

    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.BackupCodes.title
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<BackupCodesView>.self)
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
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .instructions, .description:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        case .backupCodes:
            cell = self.tableView(tableView, backupCodesCellForRowAt: indexPath)
        
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
    
    func tableView(_ tableView: UITableView, backupCodesCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<BackupCodesView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? BackupCodesViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }

    // MARK: - User Interaction
    
    override func buttonTapped() {
        super.buttonTapped()
        
        // TODO: Add continue action
    }
    
    private func getCodesTapped() {
        // TODO: Add action to get new codes from BE
    }

    // MARK: - BackupCodesResponseDisplay

    // MARK: - Additional Helpers
}
