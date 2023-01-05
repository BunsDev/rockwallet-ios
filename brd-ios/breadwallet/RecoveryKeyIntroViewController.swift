//
//  RecoveryKeyIntroViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 04/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

typealias DidExitRecoveryKeyIntroWithAction = ((ExitRecoveryKeyAction) -> Void)

//
// Screen displayed when the user wants to generate a recovery key or view the words and
// write it down again.
//
class RecoveryKeyIntroViewController: BaseTableViewController<BaseCoordinator,
                                      RecoveryKeyIntroInteractor,
                                      RecoveryKeyIntroPresenter,
                                      RecoveryKeyIntroStore>,
                                      RecoveryKeyIntroResponseDisplays {
    typealias Models = RecoveryKeyIntroModels
    
    override var isModalDismissableEnabled: Bool { return false }
    
    var exitCallback: DidExitRecoveryKeyIntroWithAction?
    
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
        
        verticalButtons.layoutIfNeeded()
        
        tableView.contentInset.bottom = verticalButtons.wrappedView.frame.height
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = LightColors.Background.one
        tableView.backgroundColor = LightColors.Background.one
        navigationController?.navigationBar.backgroundColor = LightColors.Background.one
        
        let helpButton = UIButton.buildHelpBarButton(tapped: {
            let model = PopupViewModel(title: .text("What is “Recovery Phrase”?"),
                                       body: """
Your Recovery Phrase consists of 12 randomly generated words that the wallet creates for you automatically when you start a new wallet.

The Recovery Phrase is critically important and should be written down and stored in a safe location. In the event of phone theft, destruction or loss, the Recovery Phrase can be used to load your wallet onto a new phone. The Recovery Phrase is also required when upgrading your current phone to a new one.
""")
            
            self.showInfoPopup(with: model)
        })
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: helpButton)]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section] as? Models.Section
        
        let cell: UITableViewCell
        switch section {
        case .title:
            cell = self.tableView(tableView, titleLabelCellForRowAt: indexPath)
            cell.setupCustomMargins(vertical: .extraSmall, horizontal: .large)
            
            let castedCell = cell as? WrapperTableViewCell<FELabel>
            castedCell?.setup { view in
                view.configure(with: .init(font: Fonts.Title.six,
                                           textColor: LightColors.Text.three,
                                           textAlignment: .center))
            }
            
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            
            (cell as? WrapperTableViewCell<FEImageView>)?.wrappedView.snp.makeConstraints({ make in
                make.height.equalTo(ViewSizes.illustration.rawValue)
            })
            
        case .writePhrase, .keepPhrasePrivate, .storePhraseSecurely:
            cell = self.tableView(tableView, titleSubtitleCellForRowAt: indexPath)
            cell.setupCustomMargins(vertical: .zero, horizontal: .large)
            
        case .tickbox:
            cell = self.tableView(tableView, tickboxCellForRowAt: indexPath)
            cell.setupCustomMargins(vertical: .small, horizontal: .zero)
            
            (cell as? WrapperTableViewCell<TickboxItemView>)?.wrappedView.didToggleTickbox = { [weak self] value in
                self?.tickboxToggled(value: value)
            }
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        
        return cell
    }
    
    // MARK: - User Interaction
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        if let exit = exitCallback {
            exit(.generateKey)
        }
    }
    
    func tickboxToggled(value: Bool) {
        interactor?.toggleTickbox(viewAction: .init(value: value))
    }
    
    // MARK: - RecoveryKeyIntroResponseDisplay
    
    func displayToggleTickbox(responseDisplay: RecoveryKeyIntroModels.Tickbox.ResponseDisplay) {
        continueButton.viewModel?.enabled = responseDisplay.model.enabled
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    // MARK: - Additional Helpers
    
}
