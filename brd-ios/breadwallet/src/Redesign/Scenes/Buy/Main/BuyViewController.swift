//
//  BuyViewController.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//
//

import UIKit
import LinkKit

typealias PlaidLinkKitHandler = Handler

protocol LinkOAuthHandling {
    var plaidHandler: PlaidLinkKitHandler? { get }
}

class BuyViewController: BaseExchangeTableViewController<ExchangeCoordinator,
                         BuyInteractor,
                         BuyPresenter,
                         BuyStore>,
                         BuyResponseDisplays,
                         Subscriber {
    typealias Models = BuyModels
    
    var plaidHandler: LinkKit.Handler?
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.Buy(type: dataStore?.paymentMethod?.rawValue ?? ""))
        
        Store.subscribe(self, name: .reloadBuy) { [weak self] _ in
            self?.prepareData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        getRateAndTimerCell()?.wrappedView.invalidate()
    }
    
    override var sceneLeftAlignedTitle: String? {
        return dataStore?.canUseAch == true ? nil : L10n.Button.buy
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        didTriggerExchangeRate = { [weak self] in
            self?.interactor?.getData(viewAction: .init())
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .segment:
            cell = self.tableView(tableView, segmentControlCellForRowAt: indexPath)
            
        case .accountLimits:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .rateAndTimer:
            cell = self.tableView(tableView, timerCellForRowAt: indexPath)
            
        case .from:
            cell = self.tableView(tableView, cryptoSelectionCellForRowAt: indexPath)
            
        case .paymentMethod:
            cell = self.tableView(tableView, paymentSelectionCellForRowAt: indexPath)
            
        case .increaseLimits:
            cell = self.tableView(tableView, increaseLimitsCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(all: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cryptoSelectionCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<SwapCurrencyView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? SwapCurrencyViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(shadow: Presets.ExchangeView.shadow,
                                       background: Presets.ExchangeView.background))
            view.setup(with: model)
            
            view.didChangeFiatAmount = { [weak self] value in
                self?.interactor?.setAmount(viewAction: .init(fiatValue: value))
            }
            
            view.didChangeCryptoAmount = { [weak self] value in
                self?.interactor?.setAmount(viewAction: .init(tokenValue: value))
            }
            
            view.didFinish = { [weak self] _ in
                self?.interactor?.setAmount(viewAction: .init())
            }
            
            view.didTapSelectAsset = { [weak self] in
                self?.interactor?.navigateAssetSelector(viewAction: .init())
            }
            
            view.didTapHeaderInfoButton = { [weak self] in
                self?.interactor?.showInstantAchPopup(viewAction: .init())
            }
        }
        
        cell.setupCustomMargins(vertical: .large, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, segmentControlCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<FESegmentControl> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? SegmentControlViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.didChangeValue = { [weak self] segment in
                self?.view.endEditing(true)
                self?.setSegment(segment)
            }
        }
        
        return cell
    }
    
    private func setSegment(_ segment: Int) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.segment.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<FESegmentControl> else { return }
        cell.wrappedView.selectSegment(index: segment)
        
        let paymentTypes = PaymentCard.PaymentType.allCases
        if paymentTypes.count >= segment {
            let paymentType = paymentTypes[segment]
            interactor?.selectPaymentMethod(viewAction: .init(method: paymentType))
        }
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
                                       isUserInteractionEnabled: dataStore?.isCustomLimits ?? false))
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
    
    // MARK: - BuyResponseDisplay
    
    func displayNavigateAssetSelector(responseDisplay: BuyModels.AssetSelector.ResponseDisplay) {
        coordinator?.showAssetSelector(title: responseDisplay.title,
                                       currencies: dataStore?.currencies,
                                       supportedCurrencies: dataStore?.supportedCurrencies) { [weak self] model in
            guard let model = model as? AssetViewModel else { return }
            
            guard !model.isDisabled else {
                self?.interactor?.showAssetSelectionMessage(viewAction: .init())
                
                return
            }
            
            self?.coordinator?.dismissFlow()
            
            self?.interactor?.setAssets(viewAction: .init(currency: model.subtitle))
        }
    }
    
    func displayAssetSelectionMessage(responseDisplay: BuyModels.AssetSelectionMessage.ResponseDisplay) {
        coordinator?.showToastMessage(model: responseDisplay.model, configuration: responseDisplay.config)
    }
    
    func displayPaymentCards(responseDisplay: BuyModels.PaymentCards.ResponseDisplay) {
        view.endEditing(true)
        
        coordinator?.showCardSelector(cards: responseDisplay.allPaymentCards, selected: { [weak self] selectedCard in
            guard let selectedCard = selectedCard else { return }
            self?.interactor?.setAssets(viewAction: .init(card: selectedCard))
        }, completion: { [weak self] in
            self?.interactor?.getPayments(viewAction: .init())
        })
    }
    
    func displayAssets(responseDisplay actionResponse: BuyModels.Assets.ResponseDisplay) {
        guard let fromSection = sections.firstIndex(where: { $0.hashValue == Models.Section.from.hashValue }),
              let toSection = sections.firstIndex(where: { $0.hashValue == Models.Section.paymentMethod.hashValue }),
              let fromCell = tableView.cellForRow(at: IndexPath(row: 0, section: fromSection)) as? WrapperTableViewCell<SwapCurrencyView>,
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
    
    func displayOrderPreview(responseDisplay: BuyModels.OrderPreview.ResponseDisplay) {
        coordinator?.showOrderPreview(type: .buy,
                                      coreSystem: dataStore?.coreSystem,
                                      keyStore: dataStore?.keyStore,
                                      to: dataStore?.toAmount,
                                      from: dataStore?.from,
                                      card: dataStore?.selected,
                                      quote: dataStore?.quote,
                                      availablePayments: responseDisplay.availablePayments)
    }
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        if responseDisplay.error != nil {
            LoadingView.hideIfNeeded()
        }
        
        guard !isAccessDenied(responseDisplay: responseDisplay) else { return }
        
        if responseDisplay.error != nil {
            continueButton.viewModel?.enabled = false
            verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
        }
        
        super.displayMessage(responseDisplay: responseDisplay)
    }
    
    func displayAchData(responseDisplay: BuyModels.AchData.ResponseDisplay) {
        interactor?.getPayments(viewAction: .init())
    }
    
    func displayLimitsInfo(responseDisplay: BuyModels.LimitsInfo.ResponseDisplay) {
        let _: WrapperPopupView<LimitsPopupView>? = coordinator?.showPopup(with: responseDisplay.config,
                                                                           viewModel: responseDisplay.viewModel,
                                                                           confirmedCallback: { [weak self] in
            self?.coordinator?.dismissFlow()
        })
    }
    
    func displayInstantAchPopup(responseDisplay: BuyModels.InstantAchPopup.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    // MARK: - Additional Helpers
    
    func updatePaymentMethod(paymentMethod: PaymentCard.PaymentType?) {
        guard let filteredIndex = PaymentCard.PaymentType.allCases.firstIndex(where: { $0 == paymentMethod }) else { return }
        
        let paymentMethod = paymentMethod ?? .card
        
        interactor?.retryPaymentMethod(viewAction: .init(method: paymentMethod))
        
        setSegment(filteredIndex)
    }
    
    private func mapStructToDictionary<T>(item: T) -> [String: Any] {
        let dictionary = Dictionary(uniqueKeysWithValues:
            Mirror(reflecting: item).children.lazy.map({ (label: String?, value: Any) in
                if let label = label {
                    return (label, value)
                } else {
                    return (Date().timeIntervalSince1970.description, value)
                }
            })
        )
        return dictionary.compactMapValues { $0 }
    }
}
