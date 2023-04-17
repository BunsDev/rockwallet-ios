//
//  AuthenticatorAppViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class AuthenticatorAppViewController: BaseTableViewController<AccountCoordinator,
                                      AuthenticatorAppInteractor,
                                      AuthenticatorAppPresenter,
                                      AuthenticatorAppStore>,
                                      AuthenticatorAppResponseDisplays {
    typealias Models = AuthenticatorAppModels

    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Authentication.title
    }

    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<EnterCodeView>.self)
        tableView.register(WrapperTableViewCell<OrderView>.self)
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: L10n.Button.continueAction,
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
        case .importWithLink:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
            cell.setBackground(with: Presets.Background.transparent)
            (cell as? WrapperTableViewCell<FELabel>)?.wrappedView.setBackground(with: .init(backgroundColor: LightColors.Background.two,
                                                                                            tintColor: LightColors.Background.two,
                                                                                            border: .init(borderWidth: 0,
                                                                                                          cornerRadius: CornerRadius.common)))
            cell.contentView.setupCustomMargins(vertical: .large, horizontal: .large)
            
            let wrappedCell = cell as? WrapperTableViewCell<FELabel>
            wrappedCell?.isUserInteractionEnabled = true
            wrappedCell?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(importWithLinkTapped(_:))))
            
        case .divider:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
            cell.setupCustomMargins(vertical: .large, horizontal: .large)
            (cell as? WrapperTableViewCell<FELabel>)?.wrappedView.configure(with: .init(font: Fonts.Subtitle.two,
                                                                                        textColor: LightColors.Text.three,
                                                                                        textAlignment: .center,
                                                                                        numberOfLines: 1))
            
        case .instructions:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
            cell.setBackground(with: Presets.Background.transparent)
            cell.setupCustomMargins(vertical: .large, horizontal: .large)
            
        case .qrCode:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            
            cell.setBackground(with: Presets.Background.transparent)
            cell.setupCustomMargins(vertical: .large, horizontal: .large)
            
            (cell as? WrapperTableViewCell<FEImageView>)?.wrappedView.snp.makeConstraints({ make in
                make.height.equalTo(ViewSizes.extraExtraHuge.rawValue * 2)
            })
            
        case .enterCodeManually:
            cell = self.tableView(tableView, enterCodeCellForRowAt: indexPath)
            
            cell.setBackground(with: Presets.Background.transparent)
            cell.setupCustomMargins(vertical: .large, horizontal: .large)
            
        case .copyCode:
            cell = self.tableView(tableView, copyCodeCellForRowAt: indexPath)
            
            cell.setBackground(with: Presets.Background.transparent)
            cell.setupCustomMargins(vertical: .large, horizontal: .large)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, enterCodeCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<EnterCodeView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? EnterCodeViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, copyCodeCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<OrderView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? OrderViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: Presets.Order.small)
            view.setup(with: model)
            
            view.didCopyValue = { [weak self] value in
                self?.interactor?.copyValue(viewAction: .init(value: value))
            }
        }
        
        return cell
    }
    
    // MARK: - User Interaction
    
    override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.next(viewAction: .init())
    }
    
    @objc private func importWithLinkTapped(_ sender: Any) {
        
    }

    // MARK: - AuthenticatorAppResponseDisplay
    
    func displayNext(responseDisplay: AuthenticatorAppModels.Next.ResponseDisplay) {
        coordinator?.showRegistrationConfirmation(isModalDismissable: true, confirmationType: .twoStepApp)
    }
    
    // MARK: - Additional Helpers
}
