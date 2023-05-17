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
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .accountLimits:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .increaseLimits:
            cell = self.tableView(tableView, increaseLimitsCellForRowAt: indexPath)
            
        case .rateAndTimer:
            cell = self.tableView(tableView, timerCellForRowAt: indexPath)
            
        case .swapCard:
            cell = self.tableView(tableView, swapMainCellForRowAt: indexPath)
            
        case .paymentMethod:
            cell = self.tableView(tableView, paymentSelectionCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .zero, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, swapMainCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<MainSwapView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? MainSwapViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(shadow: Presets.ExchangeView.shadow,
                                       background: Presets.ExchangeView.background))
            view.setup(with: model)
            
            view.didChangeFromCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(tokenValue: amount))
            }
            
            view.didChangeToCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(fiatValue: amount))
            }
            
            view.didFinish = { [weak self] _ in
                self?.interactor?.prepareFees(viewAction: .init())
            }
            
            view.didTapFromAssetsSelection = { [weak self] in
                self?.interactor?.navigateAssetSelector(viewAction: .init())
            }
            
            view.setupCustomMargins(top: .zero, leading: .zero, bottom: .medium, trailing: .zero)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, labelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.three,
                                       textColor: LightColors.Text.two,
                                       isUserInteractionEnabled: true))
            view.setup(with: model)
            
            view.didTapLink = { [weak self] in
                self?.interactor?.showLimitsInfo(viewAction: .init())
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, increaseLimitsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.three,
                                       textColor: LightColors.Text.two,
                                       isUserInteractionEnabled: true))
            view.setup(with: model)
            
            view.didTapLink = { [weak self] in
                self?.increaseLimitsTapped()
            }
        }
        
        return cell
    }
    
    func getRateAndTimerCell() -> WrapperTableViewCell<ExchangeRateView>? {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.rateAndTimer.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<ExchangeRateView> else {
            continueButton.viewModel?.enabled = false
            continueButton.setup(with: continueButton.viewModel)
            verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
            
            return nil
        }
        
        return cell
    }
    
    func getAccountLimitsCell() -> WrapperTableViewCell<FELabel>? {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.accountLimits.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<FELabel> else {
            return nil
        }
        return cell
    }
    
    // MARK: - User Interaction
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.showOrderPreview(viewAction: .init())
    }
    
    private func increaseLimitsTapped() {
        coordinator?.showInWebView(urlString: Constant.limits, title: L10n.Buy.increaseYourLimits)
    }
    
    // MARK: - SellResponseDisplay
    
    func displayNavigateAssetSelector(responseDisplay: SellModels.AssetSelector.ResponseDisplay) {
        coordinator?.showAssetSelector(title: responseDisplay.title,
                                       currencies: dataStore?.currencies,
                                       supportedCurrencies: dataStore?.supportedCurrencies) { [weak self] model in
            guard let model = model as? AssetViewModel else { return }
            
            guard !model.isDisabled else {
                self?.interactor?.showAssetSelectionMessage(viewAction: .init())
                
                return
            }
            
            self?.coordinator?.dismissFlow()
            self?.interactor?.setAmount(viewAction: .init(currency: model.subtitle))
        }
    }
    
    func displayAssetSelectionMessage(responseDisplay: SellModels.AssetSelectionMessage.ResponseDisplay) {
        coordinator?.showToastMessage(model: responseDisplay.model, configuration: responseDisplay.config)
    }
    
    func displayPaymentCards(responseDisplay: SellModels.PaymentCards.ResponseDisplay) {
        view.endEditing(true)
        
        coordinator?.showCardSelector(cards: responseDisplay.allPaymentCards, selected: { [weak self] selectedCard in
            guard let selectedCard = selectedCard else { return }
            self?.interactor?.setAmount(viewAction: .init(card: selectedCard))
        }, completion: { [weak self] in
            self?.interactor?.getPayments(viewAction: .init())
        })
    }
    
    func displayAmount(responseDisplay actionResponse: SellModels.Assets.ResponseDisplay) {
        guard let fromSection = sections.firstIndex(where: { $0.hashValue == Models.Section.swapCard.hashValue }),
              let toSection = sections.firstIndex(where: { $0.hashValue == Models.Section.paymentMethod.hashValue }),
              let fromCell = tableView.cellForRow(at: IndexPath(row: 0, section: fromSection)) as? WrapperTableViewCell<MainSwapView>,
              let toCell = tableView.cellForRow(at: IndexPath(row: 0, section: toSection)) as? WrapperTableViewCell<CardSelectionView> else {
            continueButton.viewModel?.enabled = false
            verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
            
            return
        }
        
        fromCell.wrappedView.setup(with: actionResponse.cryptoModel)
        toCell.wrappedView.setup(with: actionResponse.cardModel)
        
        tableView.invalidateTableViewIntrinsicContentSize()
        
        continueButton.viewModel?.enabled = dataStore?.isFormValid ?? false
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    func displayOrderPreview(responseDisplay: SellModels.OrderPreview.ResponseDisplay) {
        dataStore?.createTransactionModel = .init(exchange: dataStore?.exchange,
                                                  currencies: dataStore?.currencies,
                                                  fromFeeBasis: dataStore?.fromFeeBasis,
                                                  fromFeeAmount: dataStore?.fromFeeAmount,
                                                  fromAmount: dataStore?.fromAmount,
                                                  toAmountCode: Constant.usdCurrencyCode)
        
        coordinator?.showOrderPreview(type: .sell,
                                      coreSystem: dataStore?.coreSystem,
                                      keyStore: dataStore?.keyStore,
                                      to: dataStore?.fromAmount,
                                      from: dataStore?.toAmount,
                                      card: dataStore?.ach,
                                      quote: dataStore?.quote,
                                      availablePayments: responseDisplay.availablePayments)
    }
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        super.displayMessage(responseDisplay: responseDisplay)
        
        continueButton.viewModel?.enabled = responseDisplay.error == nil
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    func displayAchData(responseDisplay: SellModels.AchData.ResponseDisplay) {
        interactor?.getPayments(viewAction: .init())
    }
    
    func displayLimitsInfo(responseDisplay: SellModels.LimitsInfo.ResponseDisplay) {
        let _: WrapperPopupView<LimitsPopupView>? = coordinator?.showPopup(with: responseDisplay.config,
                                                                           viewModel: responseDisplay.viewModel,
                                                                           confirmedCallback: { [weak self] in
            self?.coordinator?.dismissFlow()
        })
    }
    
    func displayInstantAchPopup(responseDisplay: SellModels.InstantAchPopup.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    func displayAch(responseDisplay: AchPaymentModels.Get.ResponseDisplay) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.paymentMethod.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<CardSelectionView> else { return }
        
        cell.wrappedView.setup(with: responseDisplay.viewModel)
        
        tableView.invalidateTableViewIntrinsicContentSize()
        
        continueButton.viewModel?.enabled = dataStore?.isFormValid ?? false
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
}
