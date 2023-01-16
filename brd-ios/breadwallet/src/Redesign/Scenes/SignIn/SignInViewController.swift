//
//  SignInViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SignInViewController: BaseTableViewController<RegistrationCoordinator,
                            SignInInteractor,
                            SignInPresenter,
                            SignInStore>,
                            SignInResponseDisplays {
    typealias Models = SignInModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Account.signIn
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
        
        let partOneAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: LightColors.Text.two,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.font: Fonts.Body.two]
        let partTwoAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: LightColors.secondary,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font: Fonts.Subtitle.two]
        
        let partOne = NSMutableAttributedString(string: L10n.Account.newToRockwallet + " ", attributes: partOneAttributes)
        let partTwo = NSMutableAttributedString(string: L10n.Account.createAccountButton, attributes: partTwoAttributes)
        let createAccountButtonTitle = NSMutableAttributedString()
        createAccountButtonTitle.append(partOne)
        createAccountButtonTitle.append(partTwo)
        
        createAccountButton.configure(with: Presets.Button.noBorders)
        createAccountButton.setup(with: .init(attributedTitle: createAccountButtonTitle,
                                              isUnderlined: true,
                                              enabled: true,
                                              callback: { [weak self] in
            self?.buttonTapped()
        }))
        
        guard let continueButtonConfig = continueButton.config,
              let continueButtonModel = continueButton.viewModel,
              let createAccountButtonConfig = createAccountButton.config,
              let createAccountButtonModel = createAccountButton.viewModel else { return }
        verticalButtons.wrappedView.configure(with: .init(buttons: [continueButtonConfig, createAccountButtonConfig]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [continueButtonModel, createAccountButtonModel]))
        
        verticalButtons.layoutIfNeeded()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
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
            
        case .password:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<FETextField>
            castedCell?.setup { view in
                var emailConfig = Presets.TextField.primary
                emailConfig.autocapitalizationType = UITextAutocapitalizationType.none
                emailConfig.autocorrectionType = .no
                emailConfig.isSecureTextEntry = true
                
                view.configure(with: emailConfig)
            }
            
        case .forgotPassword:
            cell = self.tableView(tableView, buttonsCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, buttonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, buttonsCellForRowAt: indexPath)
        
        guard let cell = cell as? WrapperTableViewCell<ScrollableButtonsView> else {
            return cell
        }
        
        cell.setup { view in
            view.configure(with: .init(buttons: [Presets.Button.noBorders], isRightAligned: true))
            
            view.callbacks = [
                forgotPasswordTapped
            ]
        }
        
        return cell
    }
    
    // MARK: - User Interaction
    
    override func textFieldDidUpdate(for indexPath: IndexPath, with text: String?, on section: AnyHashable) {
        super.textFieldDidUpdate(for: indexPath, with: text, on: section)
        
        switch section as? Models.Section {
        case .email:
            interactor?.validate(viewAction: .init(email: text))
            
        case .password:
            interactor?.validate(viewAction: .init(password: text))
            
        default:
            break
        }
    }
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.next(viewAction: .init())
    }
    
    private func forgotPasswordTapped() {
        coordinator?.showForgotPassword()
    }
    
    // MARK: - SignInResponseDisplay
    
    func displayValidate(responseDisplay: SignInModels.Validate.ResponseDisplay) {
        continueButton.viewModel?.enabled = responseDisplay.isValid
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    func displayNext(responseDisplay: SignInModels.Next.ResponseDisplay) {
        coordinator?.dismissFlow()
    }
    
    // MARK: - Additional Helpers
    
}
