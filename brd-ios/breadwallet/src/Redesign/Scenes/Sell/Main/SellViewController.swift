//
//  SellViewController.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit
import LinkKit

class SellViewController: BaseExchangeTableViewController<ExchangeCoordinator,
                          SellInteractor,
                          SellPresenter,
                          SellStore>,
                          SellResponseDisplays {
    
    typealias Models = ExchangeModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Sell.title
    }
    
    var plaidHandler: PlaidLinkKitHandler?
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.Sell())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        getRateAndTimerCell()?.wrappedView.invalidate()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        didTriggerExchangeRate = { [weak self] in
            self?.interactor?.getExchangeRate(viewAction: .init(), completion: {})
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .accountLimits:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .rateAndTimer:
            cell = self.tableView(tableView, timerCellForRowAt: indexPath)
            
        case .swapCard:
            cell = self.tableView(tableView, swapMainCellForRowAt: indexPath)
            
        case .payoutMethod:
            cell = self.tableView(tableView, paymentSelectionCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .zero, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, swapMainCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<MainSwapView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? MainSwapViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(shadow: Presets.ExchangeView.shadow,
                                       background: Presets.ExchangeView.background))
            view.setup(with: model)
            
            view.didChangeFromCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(from: amount))
            }
            
            view.didChangeToCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(to: amount))
            }
            
            view.contentSizeChanged = { [weak self] in
                self?.invalidateTableViewIntrinsicContentSize()
            }
            
            view.setupCustomMargins(top: .zero, leading: .zero, bottom: .medium, trailing: .zero)
        }
        
        return cell
    }
    
    func getRateAndTimerCell() -> WrapperTableViewCell<ExchangeRateView>? {
        guard let section = sections.firstIndex(of: Models.Section.rateAndTimer),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<ExchangeRateView> else {
            return nil
        }
        
        return cell
    }
    
    func getAccountLimitsCell() -> WrapperTableViewCell<FELabel>? {
        guard let section = sections.firstIndex(of: Models.Section.accountLimits),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FELabel> else {
            return nil
        }
        return cell
    }
    
    // MARK: - User Interaction
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        coordinator?.showOrderPreview(type: .sell,
                                      coreSystem: dataStore?.coreSystem,
                                      keyStore: dataStore?.keyStore,
                                      to: dataStore?.fromAmount,
                                      from: dataStore?.toAmount,
                                      card: dataStore?.ach,
                                      quote: dataStore?.quote,
                                      availablePayments: [])
    }
    
    // MARK: - SellResponseDisplay
    
    func displayAch(responseDisplay: AchPaymentModels.Get.ResponseDisplay) {
        guard let section = sections.firstIndex(of: Models.Section.payoutMethod),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<CardSelectionView> else { return }
        
        cell.wrappedView.setup(with: responseDisplay.viewModel)
        
        invalidateTableViewIntrinsicContentSize()
        
        continueButton.viewModel?.enabled = dataStore?.isFormValid ?? false
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
}
