//
//  SellViewController.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

class SellViewController: BaseTableViewController<SellCoordinator,
                            SellInteractor,
                            SellPresenter,
                            SellStore>,
                            SellResponseDisplays {
    typealias Models = SellModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Scenes.Sell.title
    }
    
    var didTriggerGetExchangeRate: (() -> Void)?
    
    lazy var continueButton: FEButton = {
        let view = FEButton()
        return view
    }()
    
    // MARK: - Overrides
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        getRateAndTimerCell()?.wrappedView.invalidate()
    }
    
    override func prepareData() {
        super.prepareData()
        
        guard let token = dataStore?.currency else { return }
        
        sections = [
            Models.Sections.rateAndTimer,
            Models.Sections.swapCard,
            Models.Sections.accountLimits
        ]
        
        sectionRows = [
            Models.Sections.rateAndTimer: [
                ExchangeRateViewModel(exchangeRate: "1USDC = 0.9 USD",
                                      timer: .init(till: 56, repeats: false),
                                      showTimer: true)
            ],
            Models.Sections.swapCard: [
                MainSwapViewModel(from: .init(amount: .zero(token), formattedTokenString: .init(string: "0.00"), title: .text("I have 10.12000473 USDC"), selectionDisabled: true),
                             to: .init(formattedTokenString: .init(string: "0.00"), title: .text("I receive")),
                                 hideSwapButton: true)
            ],
            Models.Sections.accountLimits: [
                LabelViewModel.text(L10n.Scenes.Sell.disclaimer("50 USD", "100 USD", "1000 USD"))
            ]
        ]
        
        tableView.reloadData()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<MainSwapView>.self)
        tableView.delaysContentTouches = false
        
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: L10n.Button.confirm,
                                         enabled: false,
                                         callback: { [weak self] in
            self?.buttonTapped()
        }))
        
        guard let config = continueButton.config, let model = continueButton.viewModel else { return }
        verticalButtons.wrappedView.configure(with: .init(buttons: [config]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [model]))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Sections {
        case .accountLimits:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .rateAndTimer:
            cell = self.tableView(tableView, timerCellForRowAt: indexPath)
            
        case .swapCard:
            cell = self.tableView(tableView, swapMainCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(all: .large)
        
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
            
            view.contentSizeChanged = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            
            view.setupCustomMargins(top: .zero, leading: .zero, bottom: .medium, trailing: .zero)
        }
        
        return cell
    }
    
    private func getRateAndTimerCell() -> WrapperTableViewCell<ExchangeRateView>? {
        guard let section = sections.firstIndex(of: Models.Sections.rateAndTimer),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<ExchangeRateView> else {
            continueButton.viewModel?.enabled = false
            verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
            
            return nil
        }
        
        return cell
    }
    
    // MARK: - User Interaction

    @objc override func buttonTapped() {
        super.buttonTapped()
        
//        interactor?.showConfirmation(viewAction: .init())
    }
    
    // MARK: - SwapResponseDisplay
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        if responseDisplay.error != nil {
            LoadingView.hide()
        }
        
        guard !isAccessDenied(responseDisplay: responseDisplay) else { return }
        
        guard let error = responseDisplay.error as? ExchangeErrors else {
            coordinator?.hideMessage()
            return
        }
        
        switch error {
        case .noQuote:
            displayExchangeRate(responseDisplay: .init(rateAndTimer: .init()))
            
//        case .failed:
//            coordinator?.showFailure()
            
        default:
            coordinator?.showMessage(with: responseDisplay.error,
                                     model: responseDisplay.model,
                                     configuration: responseDisplay.config)
        }
    }
    
    func displayAmount(responseDisplay: SwapModels.Amounts.ResponseDisplay) {
        // TODO: Extract to VIPBaseViewController
        LoadingView.hide()
        
        continueButton.viewModel?.enabled = responseDisplay.continueEnabled
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
        
        tableView.beginUpdates()
        
        guard let section = sections.firstIndex(of: Models.Sections.swapCard),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<MainSwapView> else { return }
        
        cell.setup { view in
            view.setToggleSwitchPlacesButtonState(true)
            
            view.setup(with: responseDisplay.amounts)
        }
        
        tableView.endUpdates()
    }
    
    func displayExchangeRate(responseDisplay: SwapModels.Rate.ResponseDisplay) {
        tableView.beginUpdates()
        
        if let cell = getRateAndTimerCell() {
            cell.setup { view in
                view.setup(with: responseDisplay.rateAndTimer)
                
                view.completion = { [weak self] in
//                    self?.interactor?.getExchangeRate(viewAction: .init(getFees: true))
                }
            }
        }
        
        if let section = sections.firstIndex(of: Models.Sections.accountLimits),
           let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FELabel> {
            cell.setup { view in
                view.setup(with: responseDisplay.accountLimits)
            }
        }
        
        tableView.endUpdates()
    }
    
    func displaySelectAsset(responseDisplay: SwapModels.Assets.ResponseDisplay) {
        view.endEditing(true)
        
//        coordinator?.showAssetSelector(title: responseDisplay.title,
//                                       currencies: responseDisplay.to ?? responseDisplay.from,
//                                       supportedCurrencies: dataStore?.supportedCurrencies,
//                                       selected: { [weak self] model in
//            guard let model = model as? AssetViewModel else { return }
//
//            guard responseDisplay.from?.isEmpty == false else {
//                self?.interactor?.assetSelected(viewAction: .init(to: model.subtitle))
//                return
//            }
//            self?.interactor?.assetSelected(viewAction: .init(from: model.subtitle))
//        })
    }
    
    func displayConfirmation(responseDisplay: SwapModels.ShowConfirmDialog.ResponseDisplay) {
//        let _: WrapperPopupView<SwapConfirmationView>? = coordinator?.showPopup(with: responseDisplay.config,
//                                                                                viewModel: responseDisplay.viewModel,
//                                                                                confirmedCallback: { [weak self] in
//            self?.coordinator?.showPinInput(keyStore: self?.dataStore?.keyStore) { success in
//                if success {
//                    LoadingView.show()
//
//                    self?.interactor?.confirm(viewAction: .init())
//                } else {
//                    self?.coordinator?.dismissFlow()
//                }
//            }
//        })
    }
    
    func displayConfirm(responseDisplay: SwapModels.Confirm.ResponseDisplay) {
        LoadingView.hide()
//        coordinator?.showSwapInfo(from: responseDisplay.from, to: responseDisplay.to, exchangeId: responseDisplay.exchangeId)
    }
    
    func displayError(responseDisplay: SwapModels.ErrorPopup.ResponseDisplay) {
//        interactor?.showAssetInfoPopup(viewAction: .init())
    }
    
    func displayAssetInfoPopup(responseDisplay: SwapModels.AssetInfoPopup.ResponseDisplay) {
        coordinator?.showPopup(on: self,
                               blurred: true,
                               with: responseDisplay.popupViewModel,
                               config: responseDisplay.popupConfig,
                               closeButtonCallback: coordinator?.dismissFlow,
                               callbacks: [ { [weak self] in
            self?.coordinator?.dismissFlow()
        }])
    }
    
}
