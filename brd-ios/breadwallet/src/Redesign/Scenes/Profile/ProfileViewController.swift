//
//  ProfileViewController.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

class ProfileViewController: BaseTableViewController<ProfileCoordinator,
                             ProfileInteractor,
                             ProfilePresenter,
                             ProfileStore>,
                             ProfileResponseDisplays {
    typealias Models = ProfileModels
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.Profile())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        interactor?.getData(viewAction: .init())
    }
    
    override func prepareData() {}
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section] as? Models.Section
        
        let cell: UITableViewCell
        switch section {
        case .profile:
            cell = self.tableView(tableView, profileViewCellForRowAt: indexPath)
            
        case .verification:
            cell = self.tableView(tableView, infoViewCellForRowAt: indexPath)
            cell.setupCustomMargins(vertical: .large, horizontal: .large)
            
        case .navigation:
            cell = self.tableView(tableView, navigationCellForRowAt: indexPath)
            cell.addSeparator()
            (cell as? WrapperTableViewCell<NavigationItemView>)?.wrappedView.setupCustomMargins(vertical: .minimum, horizontal: .extraLarge)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, infoViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let model = sectionRows[section]?[indexPath.row] as? InfoViewModel,
              let cell: WrapperTableViewCell<WrapperView<FEInfoView>> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.setup { view in
                var config = Presets.InfoView.verification
                
                switch (model.kyc, model.status) {
                case (.levelOne, .levelOne),
                    (.levelTwo, .levelTwo(.levelTwo)):
                    config.status = Presets.VerificationView.verified.status
                    
                case (.levelOne, .emailPending),
                    (.levelTwo, .levelTwo(.submitted)):
                    config.status = Presets.VerificationView.pending.status
                    
                case (.levelTwo, .levelTwo(.resubmit)),
                    (.levelTwo, .levelTwo(.declined)),
                    (.levelTwo, .levelTwo(.expired)):
                    config.status = Presets.VerificationView.resubmitAndDeclined.status
                    
                default:
                    config.status = Presets.VerificationView.resubmitAndDeclined.status
                }
                
                view.setupCustomMargins(all: .extraLarge)
                view.configure(with: config)
                view.setup(with: model)
                
                view.headerButtonCallback = { [weak self] in
                    self?.interactor?.showVerificationInfo(viewAction: .init())
                }
                
                view.trailingButtonCallback = { [weak self] in
                    switch model.status {
                    case .levelTwo(.declined):
                        self?.coordinator?.showFailure(reason: .documentVerification)
                        
                    case .levelTwo(.resubmit), .levelTwo(.expired):
                        self?.coordinator?.showFailure(reason: .documentVerificationRetry)
                        
                    default:
                        self?.coordinator?.showAccountVerification()
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] as? Models.Section {
        case .navigation:
            let indexPath = UserManager.shared.profile?.status.hasKYCLevelTwo == true ? indexPath.row : indexPath.row + 1
            interactor?.navigate(viewAction: .init(index: indexPath))
            
        default:
            return
        }
    }
    
    // MARK: - User Interaction
    
    // MARK: - ProfileResponseDisplay
    
    func displayVerificationInfo(responseDisplay: ProfileModels.VerificationInfo.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    func displayNavigation(responseDisplay: ProfileModels.Navigate.ResponseDisplay) {
        switch responseDisplay.item {
        case .paymentMethods:
            interactor?.getPaymentCards(viewAction: .init())
            
        case .preferences:
            coordinator?.showPreferences()
            
        case .security:
            coordinator?.showSecuirtySettings()
            
        case .logout:
            LoadingView.show()
            interactor?.logout(viewAction: .init())
            
        }
    }
    
    func displayPaymentCards(responseDisplay: ProfileModels.PaymentCards.ResponseDisplay) {
        coordinator?.showCardSelector(cards: responseDisplay.allPaymentCards,
                                      selected: nil,
                                      fromBuy: false)
    }
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        LoadingView.hideIfNeeded()
        
        coordinator?.dismissFlow()
        
        if let rootViewController = UIApplication.topViewController() {
            rootViewController.showToastMessage(model: responseDisplay.model,
                                                configuration: responseDisplay.config,
                                                onTapCallback: nil)
        }
    }
    
    // MARK: - Additional Helpers
}
