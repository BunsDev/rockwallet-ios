//
//  ForgotPasswordViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class ForgotPasswordViewController: BaseTableViewController<BaseCoordinator,
                                    ForgotPasswordInteractor,
                                    ForgotPasswordPresenter,
                                    ForgotPasswordStore>,
                                    ForgotPasswordResponseDisplays {
    typealias Models = ForgotPasswordModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Account.resetPasswordTitle
    }
    
    lazy var createAccountButton: FEButton = {
        let view = FEButton()
        return view
    }()
    
    // MARK: - Overrides
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: L10n.Button.continueAction,
                                         enabled: false,
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
        case .notice:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .email:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<FETextField>
            castedCell?.setup { view in
                var emailConfig = Presets.TextField.primary
                emailConfig.autocapitalizationType = UITextAutocapitalizationType.none
                emailConfig.autocorrectionType = .no
                emailConfig.keyboardType = .emailAddress
                
                view.configure(with: emailConfig)
            }
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    // MARK: - User Interaction
    
    override func textFieldDidUpdate(for indexPath: IndexPath, with text: String?, on section: AnyHashable) {
        super.textFieldDidUpdate(for: indexPath, with: text, on: section)
        
        switch section as? Models.Section {
        case .email:
            interactor?.validate(viewAction: .init(email: text))
            
        default:
            break
        }
    }
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        // TODO: Add necessary logic.
        
        coordinator?.showBottomSheetAlert(type: .emailSent)
    }
    
    // MARK: - ForgotPasswordResponseDisplay
    
    func displayValidate(responseDisplay: ForgotPasswordModels.Validate.ResponseDisplay) {
        continueButton.viewModel?.enabled = responseDisplay.isValid
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    // MARK: - Additional Helpers
    
}
