//
//  PaymailAddressViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.4.23.
//
//

import UIKit

class PaymailAddressViewController: BaseTableViewController<PaymailAddressCoordinator,
                                    PaymailAddressInteractor,
                                    PaymailAddressPresenter,
                                    PaymailAddressStore>,
                                    PaymailAddressResponseDisplays {
    typealias Models = PaymailAddressModels

    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.PaymailAddress.title
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: dataStore?.screenType?.buttonTitle,
                                         enabled: dataStore?.screenType == .paymailSetup,
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
        case .description, .emailViewTitle:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        case .emailView:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<FETextField>
            castedCell?.setup { view in
                var config = Presets.TextField.primary
                config.autocapitalizationType = UITextAutocapitalizationType.none
                config.autocorrectionType = .no
                config.keyboardType = .emailAddress
                
                view.configure(with: config)
                view.didTapTrailingView = { [weak self] in
                    self?.interactor?.copyValue(viewAction: .init(value: ""))
                }
            }
        
        case .paymail:
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
                showPaymailPopup
            ]
        }
        
        return cell
    }

    // MARK: - User Interaction
    
    override func buttonTapped() {
        super.buttonTapped()
        
        guard dataStore?.screenType == .paymailNotSetup else {
            coordinator?.goBack()
            return
        }
        
        interactor?.showSuccessBottomAlert(viewAction: .init())
    }
    
    private func showPaymailPopup() {
        interactor?.showPaymailPopup(viewAction: .init())
    }

    // MARK: - PaymailAddressResponseDisplay
    
    func displayPaymailPopup(responseDisplay: PaymailAddressModels.InfoPopup.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    func displaySuccessBottomAlert(responseDisplay: PaymailAddressModels.Success.ResponseDisplay) {
        coordinator?.showBottomSheetAlert(type: .generalSuccess, completion: { [weak self] in
            self?.coordinator?.goBack()
        })
    }

    // MARK: - Additional Helpers
}
