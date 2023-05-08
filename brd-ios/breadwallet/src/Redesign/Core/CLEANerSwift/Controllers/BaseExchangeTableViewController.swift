// 
//  BaseExchangeTableViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 03/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class BaseExchangeTableViewController<C: CoordinatableRoutes,
                                      I: Interactor,
                                      P: Presenter,
                                      DS: BaseDataStore & NSObject>: BaseTableViewController<C, I, P, DS>,
                                                                     ExchangeResponseDisplays {
    var didTriggerExchangeRate: (() -> Void)?
    
    private var didDisplayData = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard didDisplayData else { return }
        didTriggerExchangeRate?()
    }
    
    override func displayData(responseDisplay: FetchModels.Get.ResponseDisplay) {
        super.displayData(responseDisplay: responseDisplay)
        
        didDisplayData = true
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<MainSwapView>.self)
        tableView.register(WrapperTableViewCell<SwapCurrencyView>.self)
        tableView.register(WrapperTableViewCell<CardSelectionView>.self)
        tableView.delaysContentTouches = false
        tableView.backgroundColor = LightColors.Background.two
    }
    
    func tableView(_ tableView: UITableView, timerCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<ExchangeRateView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? ExchangeRateViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, paymentSelectionCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<CardSelectionView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? CardSelectionViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.didTapSelectCard = { [weak self] in
                switch (self?.dataStore as? AchDataStore)?.paymentMethod {
                case .ach:
                    (self?.interactor as? AchViewActions)?.getPlaidToken(viewAction: .init())
                default:
                    (self?.interactor as? AchViewActions)?.getPayments(viewAction: .init(openCards: true))
                }
            }
        }
        
        return cell
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        switch self {
        case is SwapViewController,
            is BuyViewController,
            is SellViewController:
            continueButton.configure(with: Presets.Button.primary)
            continueButton.setup(with: .init(title: L10n.Button.confirm,
                                             enabled: false,
                                             callback: { [weak self] in
                self?.buttonTapped()
            }))
            
            guard let config = continueButton.config, let model = continueButton.viewModel else { return }
            verticalButtons.wrappedView.configure(with: .init(buttons: [config]))
            verticalButtons.wrappedView.setup(with: .init(buttons: [model]))
            
        default:
            return
        }
    }
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        super.displayMessage(responseDisplay: responseDisplay)
        
        let error = responseDisplay.error as? NetworkingError
        
        switch error?.errorType {
        case .twoStepRequired:
            (coordinator as? BaseCoordinator)?.openModally(coordinator: AccountCoordinator.self, scene: Scenes.RegistrationConfirmation) { vc in
                vc?.dataStore?.confirmationType = error == .twoStepAppRequired ? .twoStepAppRequired : .twoStepEmailRequired
                vc?.isModalDismissable = true
                
                vc?.didDismiss = { didDismissSuccessfully in
                    guard didDismissSuccessfully else { return }
                    
                    switch vc?.dataStore?.confirmationType {
                    case .twoStepAppBackupCode:
                        (self.dataStore as? ExchangeDataStore)?.secondFactorBackup = vc?.dataStore?.code
                        
                    default:
                        (self.dataStore as? ExchangeDataStore)?.secondFactorCode = vc?.dataStore?.code
                    }
                    
                    (self.interactor as? ExchangeRateViewActions)?.getExchangeRate(viewAction: .init(getFees: true), completion: {})
                }
            }
            
        default:
            break
        }
    }
    
    // MARK: Exchange response displays
    
    func displayAmount(responseDisplay: ExchangeModels.Amounts.ResponseDisplay) {
        LoadingView.hideIfNeeded()
        
        ToastMessageManager.shared.hide()
        
        guard let section = sections.firstIndex(where: { $0.hashValue == ExchangeModels.Section.swapCard.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<MainSwapView> else { return }
        
        cell.wrappedView.setup(with: responseDisplay.amounts)
        
        tableView.invalidateTableViewIntrinsicContentSize()
        
        continueButton.viewModel?.enabled = responseDisplay.continueEnabled
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
}
