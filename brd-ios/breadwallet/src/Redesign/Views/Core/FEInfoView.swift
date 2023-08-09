// 
//  FEInfoView.swift
//  breadwallet
//
//  Created by Rok on 11/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum FEInfoViewDismissType: CGFloat {
    /// After 5 sec
    case auto = 5
    /// Tap to remove
    case tapToDismiss
    /// Non interactable
    case persistent
}

struct InfoViewConfiguration: Configurable {
    var headerLeadingImage: BackgroundConfiguration?
    var headerTitle: LabelConfiguration?
    var headerTrailing: ButtonConfiguration?
    var status: StatusViewConfiguration?
    
    var title: LabelConfiguration?
    var description: LabelConfiguration?
    
    var swapLimits: LabelConfiguration? = .init(font: Fonts.Subtitle.three, textColor: LightColors.Text.two)
    var buyLimits: LabelConfiguration? = .init(font: Fonts.Subtitle.three, textColor: LightColors.Text.two)
    var sellLimits: LabelConfiguration? = .init(font: Fonts.Subtitle.three, textColor: LightColors.Text.two)
    
    var swapLimitsValue: TitleValueConfiguration = Presets.TitleValue.bold
    var buyDailyLimitsView: TitleValueConfiguration = Presets.TitleValue.bold
    var sellLimitsView: TitleValueConfiguration = Presets.TitleValue.bold
    
    var button: ButtonConfiguration?
    var tickboxItem: TickboxItemConfiguration?
    
    var background: BackgroundConfiguration?
    var shadow: ShadowConfiguration?
}

struct InfoViewModel: ViewModel {
    var kyc: KYC?
    var headerLeadingImage: ImageViewModel?
    var headerTitle: LabelViewModel?
    var headerTrailing: ButtonViewModel?
    var status: VerificationStatus?
    
    var title: LabelViewModel?
    var description: LabelViewModel?
    
    var swapLimits: LabelViewModel?
    var buyLimits: LabelViewModel?
    var sellLimits: LabelViewModel?
    
    var swapLimitsValue: TitleValueViewModel?
    var buyDailyLimitsView: TitleValueViewModel?
    var sellLimitsView: TitleValueViewModel?
    
    var button: ButtonViewModel?
    var tickbox: TickboxItemViewModel?
    
    var dismissType: FEInfoViewDismissType = .auto
    var canUseAch: Bool = false
}

class FEInfoView: FEView<InfoViewConfiguration, InfoViewModel> {
    var headerButtonCallback: (() -> Void)?
    var trailingButtonCallback: (() -> Void)?
    var didFinish: (() -> Void)?
    var toggleTickboxCallback: ((Bool) -> Void)?
    
    // MARK: Lazy UI
    
    private lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Margins.medium.rawValue
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = Margins.small.rawValue
        return stack
    }()
    
    private lazy var headerLeadingView: FEImageView = {
        let view = FEImageView()
        view.setupCustomMargins(all: .extraSmall)
        return view
    }()
    
    private lazy var headerTitleLabel: FELabel = {
        let label = FELabel()
        return label
    }()
    
    private lazy var statusView: WrapperView<FELabel> = {
        let view = WrapperView<FELabel>()
        return view
    }()
    
    private lazy var headerTrailingButton: FEButton = {
        let view = FEButton()
        view.addTarget(self, action: #selector(headerButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let label = FELabel()
        return label
    }()
    
    private lazy var descriptionLabel: FELabel = {
        let label = FELabel()
        return label
    }()
    
    private lazy var swapLimitsLabel: FELabel = {
        let label = FELabel()
        return label
    }()
    
    private lazy var swapLimitsView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var spacerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var buyLimitsLabel: FELabel = {
        let label = FELabel()
        return label
    }()
    
    private lazy var buyDailyLimitsView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var spacerViewSell: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var sellLimitsLabel: FELabel = {
        let label = FELabel()
        return label
    }()
    
    private lazy var sellLimitsView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var bottomButton: FEButton = {
        let view = FEButton()
        view.addTarget(self, action: #selector(trailingButtonTapped), for: .touchUpInside)
        view.titleLabel?.numberOfLines = 0
        view.titleLabel?.textAlignment = .center
        view.titleLabel?.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var tickboxItemView: TickboxItemView = {
        let tickboxItemView = TickboxItemView()
        return tickboxItemView
    }()
    
    // MARK: Overrides
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        
        verticalStackView.addArrangedSubview(headerStackView)
        headerStackView.snp.makeConstraints { make in
            make.height.equalTo(Margins.huge.rawValue)
        }
        
        headerStackView.addArrangedSubview(headerLeadingView)
        headerLeadingView.snp.makeConstraints { make in
            make.width.equalTo(Margins.huge.rawValue)
        }
        
        headerStackView.addArrangedSubview(headerTitleLabel)
        headerTitleLabel.snp.makeConstraints { make in
            make.height.equalToSuperview().priority(.low)
        }
        
        headerStackView.addArrangedSubview(statusView)
        statusView.content.setupCustomMargins(vertical: .zero, horizontal: .small)
        statusView.snp.makeConstraints { make in
            make.width.equalTo(Margins.extraLarge.rawValue * 4)
        }
        
        headerStackView.addArrangedSubview(headerTrailingButton)
        headerTrailingButton.snp.makeConstraints { make in
            make.width.equalTo(Margins.huge.rawValue)
        }
        
        verticalStackView.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(Margins.large.rawValue)
        }

        verticalStackView.addArrangedSubview(descriptionLabel)
        
        verticalStackView.addArrangedSubview(swapLimitsLabel)
        verticalStackView.addArrangedSubview(swapLimitsView)
        swapLimitsView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        verticalStackView.addArrangedSubview(spacerView)
        spacerView.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview().priority(.low)
        }
        
        verticalStackView.addArrangedSubview(buyLimitsLabel)
        verticalStackView.addArrangedSubview(buyDailyLimitsView)
        buyDailyLimitsView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        verticalStackView.addArrangedSubview(spacerViewSell)
        spacerViewSell.snp.makeConstraints { make in
            make.width.equalTo(spacerView.snp.width)
        }
        
        verticalStackView.addArrangedSubview(sellLimitsLabel)
        verticalStackView.addArrangedSubview(sellLimitsView)
        sellLimitsView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        verticalStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        buttonsStackView.addArrangedSubview(bottomButton)
        
        verticalStackView.addArrangedSubview(tickboxItemView)
        tickboxItemView.snp.makeConstraints { make in
            make.height.equalTo(Margins.extraLarge.rawValue)
        }
        
        let fillerView = UIView()
        buttonsStackView.addArrangedSubview(fillerView)
        fillerView.snp.makeConstraints { make in
            make.width.greaterThanOrEqualToSuperview().priority(.medium)
        }
    }
    
    override func configure(with config: InfoViewConfiguration?) {
        guard let config = config else { return }
        
        super.configure(with: config)
        
        backgroundColor = config.background?.backgroundColor
        headerLeadingView.configure(with: config.headerLeadingImage)
        headerTitleLabel.configure(with: config.headerTitle)
        headerTrailingButton.configure(with: config.headerTrailing)
        statusView.wrappedView.configure(with: config.status?.title)
        statusView.configure(background: config.status?.background)
        
        titleLabel.configure(with: config.title)
        descriptionLabel.configure(with: config.description)
        
        swapLimitsLabel.configure(with: config.swapLimits)
        swapLimitsView.configure(with: config.swapLimitsValue)
        buyLimitsLabel.configure(with: config.buyLimits)
        buyDailyLimitsView.configure(with: config.buyDailyLimitsView)
        sellLimitsLabel.configure(with: config.sellLimits)
        sellLimitsView.configure(with: config.sellLimitsView)
        
        bottomButton.configure(with: config.button)
        tickboxItemView.configure(with: config.tickboxItem)
        
        shadowView = self
        backgroundView = self
        
        configure(background: config.background)
        configure(shadow: config.shadow)
    }
    
    override func setup(with viewModel: InfoViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        
        headerLeadingView.setup(with: viewModel.headerLeadingImage)
        headerLeadingView.isHidden = viewModel.headerLeadingImage == nil
        
        headerTitleLabel.setup(with: viewModel.headerTitle)
        headerTitleLabel.isHidden = viewModel.headerTitle == nil
        
        headerTrailingButton.setup(with: viewModel.headerTrailing)
        headerTrailingButton.isHidden = viewModel.headerTrailing == nil
        
        statusView.wrappedView.setup(with: .text(viewModel.status?.title))
        statusView.isHidden = viewModel.status == VerificationStatus.none
        
        titleLabel.setup(with: viewModel.title)
        titleLabel.isHidden = viewModel.title == nil
        
        descriptionLabel.setup(with: viewModel.description)
        descriptionLabel.isHidden = viewModel.description == nil
        
        swapLimitsLabel.setup(with: viewModel.swapLimits)
        swapLimitsLabel.isHidden = viewModel.swapLimits == nil
        spacerView.isHidden = viewModel.swapLimits == nil
        
        swapLimitsView.setup(with: viewModel.swapLimitsValue)
        swapLimitsView.isHidden = viewModel.swapLimitsValue == nil
        
        buyLimitsLabel.setup(with: viewModel.buyLimits)
        buyLimitsLabel.isHidden = viewModel.buyLimits == nil
        
        buyDailyLimitsView.setup(with: viewModel.buyDailyLimitsView)
        buyDailyLimitsView.isHidden = viewModel.buyDailyLimitsView == nil
        
        sellLimitsView.setup(with: viewModel.sellLimitsView)
        sellLimitsView.isHidden = viewModel.sellLimitsView == nil
        spacerViewSell.isHidden = viewModel.sellLimitsView == nil
        
        sellLimitsLabel.setup(with: viewModel.sellLimits)
        sellLimitsLabel.isHidden = viewModel.sellLimitsView == nil
        
        bottomButton.setup(with: viewModel.button)
        buttonsStackView.isHidden = viewModel.button == nil
        
        tickboxItemView.setup(with: viewModel.tickbox)
        tickboxItemView.isHidden = viewModel.tickbox == nil
        
        switch viewModel.dismissType {
        case .tapToDismiss, .auto:
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
            
        default:
            break
        }
        
        guard headerLeadingView.isHidden,
              headerTitleLabel.isHidden,
              headerTrailingButton.isHidden else {
            return
        }
        
        headerStackView.isHidden = true
        
        tickboxItemView.didToggleTickbox = { [weak self] value in
            self?.tickboxTapped(value: value)
        }
    }
    
    @objc private func headerButtonTapped(_ sender: UIButton?) {
        headerButtonCallback?()
    }
    
    @objc private func trailingButtonTapped(_ sender: UIButton?) {
        trailingButtonCallback?()
    }
    
    @objc private func viewTapped() {
        didFinish?()
    }
    
    func tickboxTapped(value: Bool) {
        toggleTickboxCallback?(value)
    }
}
