//
//  KYCAddressViewController.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

class KYCAddressViewController: BaseTableViewController<KYCCoordinator,
                                KYCAddressInteractor,
                                KYCAddressPresenter,
                                KYCAddressStore>,
                                KYCAddressResponseDisplays {
    
    typealias Models = KYCAddressModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Account.residentialAddress
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        setRoundedShadowBackground()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .mandatory:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
        case .country:
            cell = self.tableView(tableView, countryTextFieldCellForRowAt: indexPath)
            
        case .postalCode:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .cityAndState:
            cell = self.tableView(tableView, cityAndZipPostalCellForRowAt: indexPath)
            
        case .address:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .ssn:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .ssnInfo:
            cell = self.tableView(tableView, buttonsCellForRowAt: indexPath)
            
        case .confirm:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.contentView.setupCustomMargins(vertical: .small, horizontal: .zero)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, countryTextFieldCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? TextFieldModel,
              let cell: WrapperTableViewCell<FETextField> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: Presets.TextField.two)
            view.setup(with: model)
            
            view.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cityAndZipPostalCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<DoubleHorizontalTextboxView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? DoubleHorizontalTextboxViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.finishedEditing = { [weak self] first, second in
                self?.interactor?.formUpdated(viewAction: .init(section: section, value: (first, second)))
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, buttonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, buttonsCellForRowAt: indexPath)
        
        guard let cell = cell as? WrapperTableViewCell<HorizontalButtonsView> else {
            return cell
        }
        
        cell.setup { view in
            view.configure(with: .init(buttons: [Presets.Button.noBorders], isRightAligned: true))
            
            view.callbacks = [
                ssnInfoTapped
            ]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] as? Models.Section {
        case .country:
            interactor?.pickCountry(viewAction: .init())
            
        default:
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        let section = sections[indexPath.section]
        
        interactor?.formUpdated(viewAction: .init(section: section, value: text))
        
        super.textFieldDidFinish(for: indexPath, with: text)
    }
    
    func displayForm(responseDisplay: KYCAddressModels.FormUpdated.ResponseDisplay) {
        guard var model = sectionRows[Models.Section.confirm]?.first as? ButtonViewModel,
              model.enabled != responseDisplay.isValid
        else { return }
        
        model.enabled = responseDisplay.isValid
        sectionRows[Models.Section.confirm] = [model]
        let index = sections.firstIndex(where: { $0.hashValue == Models.Section.confirm.hashValue }) ?? 0
        tableView.reloadRows(at: [IndexPath(row: 0, section: index)], with: .none)
    }
    
    func displayExternalKYC(responseDisplay: KYCAddressModels.ExternalKYC.ResponseDisplay) {
        coordinator?.showExternalKYC(url: responseDisplay.address)
    }
    
    func displaySsnInfo(responseDisplay: KYCAddressModels.SsnInfo.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    // MARK: - User Interaction
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.submitInfo(viewAction: .init())
    }
    
    private func ssnInfoTapped() {
        interactor?.showSsnInfo(viewAction: .init())
    }
}
