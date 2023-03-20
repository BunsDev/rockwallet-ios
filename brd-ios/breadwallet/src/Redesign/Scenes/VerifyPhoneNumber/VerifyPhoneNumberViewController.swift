//
//  VerifyPhoneNumberViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class VerifyPhoneNumberViewController: BaseTableViewController<AccountCoordinator,
                                       VerifyPhoneNumberInteractor,
                                       VerifyPhoneNumberPresenter,
                                       VerifyPhoneNumberStore>,
                                       VerifyPhoneNumberResponseDisplays {
    typealias Models = VerifyPhoneNumberModels
    
    override var sceneLeftAlignedTitle: String? {
        return "Verify your phone number"
    }
    
    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<PhoneNumberView>.self)
    }
    
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
        case .instructions:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
        
        case .phoneNumber:
            cell = self.tableView(tableView, phoneNumberCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .large, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, phoneNumberCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<PhoneNumberView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? PhoneNumberViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
//            view.valueChanged = { [weak self] text in
//                self?.textFieldDidFinish(for: indexPath, with: text)
//            }
        }
        
        return cell
    }
    
    // MARK: - User Interaction
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        interactor?.validate(viewAction: .init(item: text))
        
        super.textFieldDidFinish(for: indexPath, with: text)
    }
    
    private func resendCodeTapped() {
        interactor?.resend(viewAction: .init())
    }
    
    private func changeEmailTapped() {
        coordinator?.showChangeEmail()
    }
    
    // MARK: - VerifyPhoneNumberResponseDisplay
    
    func displayConfirm(responseDisplay: VerifyPhoneNumberModels.Confirm.ResponseDisplay) {
        coordinator?.showBottomSheetAlert(type: .generalSuccess, completion: { [weak self] in
            self?.coordinator?.dismissFlow()
        })
    }
    
    // MARK: - Additional Helpers
}
