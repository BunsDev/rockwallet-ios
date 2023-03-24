//
//  HomeScreenViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-11-27.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import Combine
import UIKit
import SnapKit
import Lottie

class HomeScreenViewController: UIViewController, UITabBarDelegate, Subscriber {
    private let walletAuthenticator: WalletAuthenticator
    private let notificationHandler = NotificationHandler()
    private let coreSystem: CoreSystem
    
    private var observers: [AnyCancellable] = []
    
    private lazy var assetListTableView: AssetListTableView = {
        let view = AssetListTableView()
        return view
    }()
    
    private lazy var tabBarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CornerRadius.large.rawValue
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.backgroundColor = LightColors.Background.cards
        return view
    }()
    
    private lazy var tabBar: UITabBar = {
        let view = UITabBar()
        view.delegate = self
        view.isTranslucent = false
        let appearance = view.standardAppearance
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundColor = LightColors.Background.cards
        view.standardAppearance = appearance
        view.unselectedItemTintColor = LightColors.Text.two
        return view
    }()
    
    private lazy var subHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var totalAssetsTitleLabel: UILabel = {
        let view = UILabel(font: Fonts.Body.two, color: LightColors.Text.three)
        view.text = L10n.HomeScreen.totalAssets
        return view
    }()
    
    private lazy var totalAssetsAmountLabel: UILabel = {
        let view = UILabel(font: Fonts.Title.three, color: LightColors.Text.three)
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.textAlignment = .right
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = Asset.logoIcon.image
        return view
    }()
    
    var didSelectCurrency: ((Currency) -> Void)?
    var didTapManageWallets: (() -> Void)?
    var didTapBuy: ((PaymentCard.PaymentType) -> Void)?
    var didTapSell: (() -> Void)?
    var didTapTrade: (() -> Void)?
    var didTapProfile: (() -> Void)?
    var didTapProfileFromPrompt: ((Result<Profile?, Error>?) -> Void)?
    var didTapCreateAccountFromPrompt: (() -> Void)?
    var didTapLimitsAuthenticationFromPrompt: (() -> Void)?
    var didTapMenu: (() -> Void)?
    
    var isInExchangeFlow = false
    
    private lazy var totalAssetsNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.numberStyle = .currency
        formatter.generatesDecimalNumbers = true
        return formatter
    }()
    
    private lazy var pullToRefreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.attributedTitle = NSAttributedString(string: L10n.HomeScreen.pullToRefresh)
        view.addTarget(self, action: #selector(reload), for: .valueChanged)
        return view
    }()
    
    // We are not using pullToRefreshControl.isRefreshing because when you trigger reload() it is already refreshing. We need a variable that tracks the real refreshing of the resources.
    private var isRefreshing = false
    
    private let tabBarButtons = [(L10n.Button.home, Asset.home.image as UIImage, #selector(showHome)),
                                 (L10n.HomeScreen.trade, Asset.trade.image as UIImage, #selector(trade)),
                                 (L10n.Drawer.title, nil, #selector(buy)),
                                 (L10n.Button.profile, Asset.user.image as UIImage, #selector(profile)),
                                 (L10n.HomeScreen.menu, Asset.more.image as UIImage, #selector(menu))]
    
    let animationView: LottieAnimationView = {
        let view = LottieAnimationView(animation: Animations.buyAndSell.animation)
        return view
    }()

    // MARK: - Lifecycle
    
    init(walletAuthenticator: WalletAuthenticator, coreSystem: CoreSystem) {
        self.walletAuthenticator = walletAuthenticator
        self.coreSystem = coreSystem
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Store.unsubscribe(self)
    }
    
    @objc func reload() {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        UserManager.shared.refresh { [weak self] _ in
            PromptPresenter.shared.attemptShowGeneralPrompt(walletAuthenticator: self?.walletAuthenticator, on: self)
        }
        
        Currencies.shared.reloadCurrencies()
        
        coreSystem.refreshWallet { [weak self] in
            self?.assetListTableView.reload()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pullToRefreshControl.endRefreshing()
        
        isInExchangeFlow = false
        ExchangeCurrencyHelper.revertIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PromptPresenter.shared.attemptShowGeneralPrompt(walletAuthenticator: walletAuthenticator, on: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assetListTableView.didSelectCurrency = didSelectCurrency
        assetListTableView.didTapAddWallet = didTapManageWallets
        assetListTableView.didReload = { [weak self] in
            self?.pullToRefreshControl.endRefreshing()
            
            self?.isRefreshing = false
        }
        
        setupSubviews()
        setInitialData()
        setupSubscriptions()
        updateTotalAssets()
        
        if !Store.state.isLoginRequired {
            NotificationAuthorizer().showNotificationsOptInAlert(from: self, callback: { _ in
                self.notificationHandler.checkForInAppNotifications()
            })
        }
    }
    
    // MARK: Setup
    
    private func setupSubviews() {
        view.addSubview(subHeaderView)
        subHeaderView.addSubview(logoImageView)
        subHeaderView.addSubview(totalAssetsTitleLabel)
        subHeaderView.addSubview(totalAssetsAmountLabel)
        
        let promptContainerScrollView = PromptPresenter.shared.promptContainerScrollView
        let promptContainerStack = PromptPresenter.shared.promptContainerStack
        
        view.addSubview(promptContainerScrollView)
        promptContainerScrollView.addSubview(promptContainerStack)
        
        assetListTableView.refreshControl = pullToRefreshControl
        pullToRefreshControl.layer.zPosition = assetListTableView.view.layer.zPosition - 1
        
        subHeaderView.constrain([
            subHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: -(navigationController?.navigationBar.frame.height ?? 0) + Margins.extraHuge.rawValue),
            subHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subHeaderView.heightAnchor.constraint(equalToConstant: ViewSizes.Common.hugeCommon.rawValue) ])
        
        totalAssetsTitleLabel.constrain([
            totalAssetsTitleLabel.topAnchor.constraint(equalTo: subHeaderView.topAnchor),
            totalAssetsTitleLabel.trailingAnchor.constraint(equalTo: subHeaderView.trailingAnchor, constant: -Margins.large.rawValue)])
        
        totalAssetsAmountLabel.constrain([
            totalAssetsAmountLabel.trailingAnchor.constraint(equalTo: totalAssetsTitleLabel.trailingAnchor),
            totalAssetsAmountLabel.topAnchor.constraint(equalTo: totalAssetsTitleLabel.bottomAnchor, constant: Margins.extraSmall.rawValue),
            totalAssetsAmountLabel.bottomAnchor.constraint(equalTo: subHeaderView.bottomAnchor)])
        
        logoImageView.constrain([
            logoImageView.leadingAnchor.constraint(equalTo: subHeaderView.leadingAnchor, constant: Margins.large.rawValue),
            logoImageView.centerYAnchor.constraint(equalTo: subHeaderView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 48)])
        
        promptContainerScrollView.constrain([
            promptContainerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.large.rawValue),
            promptContainerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.large.rawValue),
            promptContainerScrollView.topAnchor.constraint(equalTo: subHeaderView.bottomAnchor, constant: Margins.medium.rawValue),
            promptContainerScrollView.heightAnchor.constraint(equalToConstant: ViewSizes.minimum.rawValue).priority(.defaultLow)])
        
        promptContainerStack.constrain([
            promptContainerStack.leadingAnchor.constraint(equalTo: promptContainerScrollView.leadingAnchor),
            promptContainerStack.trailingAnchor.constraint(equalTo: promptContainerScrollView.trailingAnchor),
            promptContainerStack.topAnchor.constraint(equalTo: promptContainerScrollView.topAnchor),
            promptContainerStack.bottomAnchor.constraint(equalTo: promptContainerScrollView.bottomAnchor),
            promptContainerStack.heightAnchor.constraint(equalTo: promptContainerScrollView.heightAnchor),
            promptContainerStack.widthAnchor.constraint(equalTo: promptContainerScrollView.widthAnchor)])
        
        addChildViewController(assetListTableView, layout: {
            assetListTableView.view.constrain([
                assetListTableView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                assetListTableView.view.topAnchor.constraint(equalTo: promptContainerScrollView.bottomAnchor, constant: Margins.medium.rawValue),
                assetListTableView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                assetListTableView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        })
        
        let drawerConfig = DrawerConfiguration()
        let drawerViewModel = DrawerViewModel()
        let drawerCallbacks: [(() -> Void)] = [ { [weak self] in
            self?.didTapDrawerButton(.card)
        }, { [weak self] in
            self?.didTapDrawerButton(.ach)
        }, { [weak self]
            in self?.didTapDrawerButton()
        }]
        setupDrawer(config: drawerConfig, viewModel: drawerViewModel, callbacks: drawerCallbacks) { [unowned self] drawer in
            drawer.dismissActionPublisher.sink { [weak self] _ in
                self?.animationView.play(fromProgress: 1, toProgress: 0)
            }.store(in: &self.observers)
        }
        
        view.addSubview(tabBarContainerView)
        tabBarContainerView.addSubview(tabBar)
        
        tabBarContainerView.constrain([
            tabBarContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarContainerView.heightAnchor.constraint(equalToConstant: ViewSizes.bottomToolbarHeight.rawValue)])
        
        tabBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Margins.large.rawValue)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.centerX.equalTo(tabBar.snp.centerX)
            make.top.equalTo(tabBarContainerView.snp.top).offset(-Margins.small.rawValue)
        }
    }
    
    private func setInitialData() {
        title = ""
        view.backgroundColor = LightColors.Background.two
        navigationItem.titleView = UIView()
        
        setupToolbar()
        updateTotalAssets()
        setupAnimationView()
    }
    
    private func didTapDrawerButton(_ type: PaymentCard.PaymentType? = nil) {
        if let type = type {
            didTapBuy?(type)
        } else {
            didTapSell?()
        }
        animationView.play(fromProgress: 1, toProgress: 0)
    }
    
    private func setupToolbar() {
        var buttons = [UITabBarItem]()
        
        tabBarButtons.forEach { title, image, _ in
            let button = UITabBarItem(title: title, image: image, selectedImage: image)
            button.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.button], for: .normal)
            var insets = button.imageInsets
            insets.bottom = Margins.extraSmall.rawValue
            insets.top = -Margins.extraSmall.rawValue
            button.imageInsets = insets
            buttons.append(button)
        }
        
        tabBar.items = buttons
    }
    
    private func setupAnimationView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(buy))
        animationView.addGestureRecognizer(gesture)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(where: { $0 == item }) else { return }
        perform(tabBarButtons[index].2)
        tabBar.selectedItem = nil
    }
    
    private func setupSubscriptions() {
        Store.unsubscribe(self)
        
        Store.subscribe(self, selector: {
            var result = false
            let oldState = $0
            let newState = $1
            $0.wallets.values.map { $0.currency }.forEach { currency in
                result = result || oldState[currency]?.balance != newState[currency]?.balance
                result = result || oldState[currency]?.currentRate?.rate != newState[currency]?.currentRate?.rate
            }
            return result
        }, callback: { _ in
            self.updateTotalAssets()
            self.updateAmountsForWidgets()
        })
        
        // Prompts
        Store.subscribe(self, name: .didUpgradePin, callback: { _ in
            PromptPresenter.shared.hidePrompt(.upgradePin)
        })
        
        Store.subscribe(self, name: .didWritePaperKey, callback: { _ in
            PromptPresenter.shared.hidePrompt(.paperKey)
        })
        
        Store.subscribe(self, name: .didApplyKyc, callback: { _ in
            PromptPresenter.shared.hidePrompt(.kyc)
        })
        
        Store.subscribe(self, name: .didCreateAccount, callback: { _ in
            PromptPresenter.shared.hidePrompt(.noAccount)
        })
        
        Store.subscribe(self, name: .didSetTwoStep, callback: { _ in
            PromptPresenter.shared.hidePrompt(.twoStep)
        })
        
        Store.subscribe(self, name: .promptKyc, callback: { _ in
            self.didTapProfileFromPrompt?(UserManager.shared.profileResult)
        })
        
        Store.subscribe(self, name: .promptNoAccount, callback: { _ in
            self.didTapCreateAccountFromPrompt?()
        })
        
        Store.subscribe(self, name: .promptTwoStep, callback: { _ in
            // TODO: Do this to do
        })
        
        Store.subscribe(self, name: .promptLimitsAuthentication, callback: { _ in
            self.didTapLimitsAuthenticationFromPrompt?()
        })
        
        Reachability.addDidChangeCallback({ [weak self] isReachable in
            PromptPresenter.shared.hidePrompt(.noInternet)
            
            if !isReachable {
                PromptPresenter.shared.attemptShowGeneralPrompt(walletAuthenticator: self?.walletAuthenticator, on: self)
            }
        })
        
        Store.subscribe(self, selector: {
            $0.wallets.count != $1.wallets.count
        }, callback: { _ in
            self.updateTotalAssets()
            self.updateAmountsForWidgets()
        })
        
        PromptPresenter.shared.trailingButtonCallback = { [weak self] promptType in
            switch promptType {
            case .kyc:
                self?.didTapProfileFromPrompt?(UserManager.shared.profileResult)
                
            case .noAccount:
                self?.didTapCreateAccountFromPrompt?()
                
            default:
                break
            }
        }
    }
    
    private func updateTotalAssets() {
        guard isInExchangeFlow == false else { return }
        
        let fiatTotal: Decimal = Store.state.wallets.values.map {
            guard let balance = $0.balance,
                  let rate = $0.currentRate else { return 0.0 }
            let amount = Amount(amount: balance,
                                rate: rate)
            return amount.fiatValue
        }.reduce(0.0, +)
        
        let localeComponents = [NSLocale.Key.currencyCode.rawValue: UserDefaults.defaultCurrencyCode]
        let localeIdentifier = Locale.identifier(fromComponents: localeComponents)
        totalAssetsNumberFormatter.locale = Locale(identifier: localeIdentifier)
        totalAssetsNumberFormatter.currencySymbol = Store.state.orderedWallets.first?.currentRate?.code ?? ""
        
        totalAssetsAmountLabel.text = totalAssetsNumberFormatter.string(from: fiatTotal as NSDecimalNumber)
    }
    
    private func updateAmountsForWidgets() {
        guard isInExchangeFlow == false else { return }
        
        let info: [CurrencyId: Double] = Store.state.wallets
            .map { ($0, $1) }
            .reduce(into: [CurrencyId: Double]()) {
                if let balance = $1.1.balance {
                    let unit = $1.1.currency.defaultUnit
                    $0[$1.0] = balance.cryptoAmount.double(as: unit) ?? 0
                }
            }
        
        coreSystem.widgetDataShareService.updatePortfolio(info: info)
        coreSystem.widgetDataShareService.quoteCurrencyCode = Store.state.defaultCurrencyCode
    }
    
    // MARK: Actions
    
    @objc private func showHome() {
        if drawerIsShown {
            animationView.play(fromProgress: 1, toProgress: 0)
        }
        hideDrawer()
    }
    
    private func commonTapAction() {
        if drawerIsShown {
            animationView.play(fromProgress: 1, toProgress: 0)
        }
        hideDrawer()
    }
    
    @objc private func buy() {
        if drawerIsShown {
            animationView.play(fromProgress: 1, toProgress: 0)
        } else {
            animationView.play()
        }
        toggleDrawer()
    }
    
    @objc private func trade() {
        commonTapAction()
        didTapTrade?()
    }
    
    @objc private func profile() {
        commonTapAction()
        didTapProfile?()
    }
    
    @objc private func menu() {
        commonTapAction()
        didTapMenu?()
    }
}
