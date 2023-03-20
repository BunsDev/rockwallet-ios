// 
//  BaseExchangeTableViewController.swift
//  breadwallet
//
//  Created by Kanan Mamedoff on 03/03/2023.
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
        
        tableView.register(WrapperTableViewCell<FESegmentControl>.self)
        tableView.register(WrapperTableViewCell<MainSwapView>.self)
        tableView.register(WrapperTableViewCell<SwapCurrencyView>.self)
        tableView.register(WrapperTableViewCell<CardSelectionView>.self)
        tableView.delaysContentTouches = false
        tableView.backgroundColor = LightColors.Background.two
    }
    
    func tableView(_ tableView: UITableView, timerCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<ExchangeRateView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? ExchangeRateViewModel
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
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<CardSelectionView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? CardSelectionViewModel
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
    
    // MARK: Exchange response displays
    
    func displayAmount(responseDisplay: ExchangeModels.Amounts.ResponseDisplay) {
        LoadingView.hideIfNeeded()
        
        guard let section = sections.firstIndex(of: ExchangeModels.Section.swapCard),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<MainSwapView> else { return }
        
        tableView.beginUpdates()
        cell.wrappedView.setup(with: responseDisplay.amounts)
        tableView.endUpdates()
        
        continueButton.viewModel?.enabled = responseDisplay.continueEnabled
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
}
