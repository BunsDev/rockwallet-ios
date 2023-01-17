//
//  SignUpViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SignUpViewController: BaseTableViewController<AccountCoordinator,
                            SignUpInteractor,
                            SignUpPresenter,
                            SignUpStore>,
                            SignUpResponseDisplays {
    typealias Models = SignUpModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Account.createNewAccountTitle
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
        
        let partOne = NSMutableAttributedString(string: L10n.Account.alreadyCreated + " ", attributes: partOneAttributes)
        let partTwo = NSMutableAttributedString(string: L10n.Account.signIn, attributes: partTwoAttributes)
        let createAccountButtonTitle = NSMutableAttributedString()
        createAccountButtonTitle.append(partOne)
        createAccountButtonTitle.append(partTwo)
        
        createAccountButton.configure(with: Presets.Button.noBorders)
        createAccountButton.setup(with: .init(attributedTitle: createAccountButtonTitle,
                                              isUnderlined: true,
                                              enabled: true,
                                              callback: { [weak self] in
            self?.signInTapped()
        }))
        
        guard let continueButtonConfig = continueButton.config,
              let continueButtonModel = continueButton.viewModel,
              let createAccountButtonConfig = createAccountButton.config,
              let createAccountButtonModel = createAccountButton.viewModel else { return }
        verticalButtons.wrappedView.configure(with: .init(buttons: [continueButtonConfig, createAccountButtonConfig]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [continueButtonModel, createAccountButtonModel]))
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
            
        case .confirmPassword:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<FETextField>
            castedCell?.setup { view in
                var emailConfig = Presets.TextField.primary
                emailConfig.autocapitalizationType = UITextAutocapitalizationType.none
                emailConfig.autocorrectionType = .no
                emailConfig.isSecureTextEntry = true
                
                view.configure(with: emailConfig)
            }
            
        case .notice:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .termsTickbox:
            cell = self.tableView(tableView, tickboxCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<TickboxItemView>
            castedCell?.setup { view in
                view.didTapUrl = { [weak self] url in
                    guard let url = url?.absoluteString else { return }
                    self?.coordinator?.showInWebView(urlString: url, title: L10n.About.terms)
                }
                
                view.didToggleTickbox = { [weak self] value in
                    self?.interactor?.toggleTermsTickbox(viewAction: .init(value: value))
                }
            }
            
        case .promotionsTickbox:
            cell = self.tableView(tableView, tickboxCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<TickboxItemView>
            castedCell?.setup { view in
                view.didTapUrl = { [weak self] url in
                    guard let url = url?.absoluteString else { return }
                    self?.coordinator?.showInWebView(urlString: url, title: L10n.About.terms)
                }
                
                view.didToggleTickbox = { [weak self] value in
                    self?.interactor?.togglePromotionsTickbox(viewAction: .init(value: value))
                }
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
            
        case .password:
            interactor?.validate(viewAction: .init(password: text))
            
        case .confirmPassword:
            interactor?.validate(viewAction: .init(passwordAgain: text))
            
        default:
            break
        }
    }
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.next(viewAction: .init())
    }
    
    @objc func signInTapped() {
        super.buttonTapped()
        
        coordinator?.showSignIn()
    }
    
    // MARK: - SignUpResponseDisplay
    
    func displayValidate(responseDisplay: SignUpModels.Validate.ResponseDisplay) {
        let isValid = responseDisplay.isEmailValid && responseDisplay.isPasswordValid && responseDisplay.isTermsTickboxValid
        continueButton.viewModel?.enabled = isValid
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
        
        guard let noticeSection = sections.firstIndex(of: Models.Section.notice),
              let noticeCell = tableView.cellForRow(at: .init(row: 0, section: noticeSection)) as? WrapperTableViewCell<FELabel> else {
            return
        }
        
        noticeCell.setup { view in
            let textColor = responseDisplay.isPasswordValid ? LightColors.Text.two : LightColors.Error.one
            view.configure(with: .init(font: Fonts.Body.three, textColor: textColor))
        }
        
        let emailCell = getFieldCell(for: .email)
        let passwordCell = getFieldCell(for: .password)
        let confirmPasswordCell = getFieldCell(for: .confirmPassword)
    }
    
    func displayNext(responseDisplay: SignUpModels.Next.ResponseDisplay) {
        coordinator?.dismissFlow()
    }
    
    // MARK: - Additional Helpers
    
    // TODO: Fix and FETextFied error state
    private func getFieldCell(for section: Models.Section) -> WrapperTableViewCell<FETextField>? {
        guard let section = sections.firstIndex(of: section),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FETextField> else {
            return nil
        }
        
        return cell
    }
}
