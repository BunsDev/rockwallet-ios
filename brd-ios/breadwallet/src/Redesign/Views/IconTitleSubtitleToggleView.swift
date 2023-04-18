// 
//  IconTitleSubtitleToggleView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 27/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct IconTitleSubtitleToggleConfiguration: Configurable {
    var icon: BackgroundConfiguration = .init(tintColor: LightColors.Text.three)
    var title: LabelConfiguration = .init(font: Fonts.Subtitle.one, textColor: LightColors.Text.three, numberOfLines: 1)
    var subtitle: LabelConfiguration = .init(font: Fonts.Subtitle.two, textColor: LightColors.Text.two, numberOfLines: 1)
    var checkmark: BackgroundConfiguration? = .init(tintColor: LightColors.primary)
    var shadow: ShadowConfiguration?
    var background: BackgroundConfiguration?
}

struct IconTitleSubtitleToggleViewModel: ViewModel {
    var icon: ImageViewModel?
    var title: LabelViewModel
    var subtitle: LabelViewModel?
    var checkmark: ImageViewModel = .image(Asset.radiobutton.image)
    var checkmarkToggle: Bool = false
    var isInteractable: Bool = true
}

class IconTitleSubtitleToggleView: FEView<IconTitleSubtitleToggleConfiguration, IconTitleSubtitleToggleViewModel> {
    var didTap: (() -> Void)?
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        return view
    }()
    
    private lazy var iconImageView: FEImageView = {
        let view = FEImageView()
        view.contentMode = .left
        return view
    }()
    
    private lazy var titleSubtitleStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var subtitleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var checkmarkImageView: FEImageView = {
        let view = FEImageView()
        view.contentMode = .right
        return view
    }()
    
    private lazy var checkmarkToggleView: UISwitch = {
        let view = UISwitch()
        return view
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = LightColors.Outline.one
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.setupCustomMargins(vertical: .extraSmall, horizontal: .zero)
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        
        mainStack.addArrangedSubview(iconImageView)
        mainStack.addArrangedSubview(titleSubtitleStack)
        titleSubtitleStack.addArrangedSubview(titleLabel)
        titleSubtitleStack.addArrangedSubview(subtitleLabel)
        mainStack.addArrangedSubview(checkmarkImageView)
        mainStack.addArrangedSubview(checkmarkToggleView)
        
        iconImageView.snp.makeConstraints { make in
            make.width.equalTo(ViewSizes.large.rawValue)
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.width.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        titleSubtitleStack.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview()
        }
        
        content.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.minimum.rawValue)
            make.leading.equalToSuperview().offset(-Margins.medium.rawValue)
            make.trailing.bottom.equalToSuperview().offset(Margins.medium.rawValue)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func configure(with config: IconTitleSubtitleToggleConfiguration?) {
        guard let config = config else { return }
        
        super.configure(with: config)
        
        iconImageView.configure(with: config.icon)
        titleLabel.configure(with: config.title)
        subtitleLabel.configure(with: config.subtitle)
        checkmarkImageView.configure(with: config.checkmark)
        
        shadowView = self
        backgroundView = self
        
        configure(background: config.background)
        configure(shadow: config.shadow)
    }
    
    override func setup(with viewModel: IconTitleSubtitleToggleViewModel?) {
        super.setup(with: viewModel)
        
        iconImageView.setup(with: viewModel?.icon)
        iconImageView.isHidden = viewModel?.icon == nil
        titleLabel.setup(with: viewModel?.title)
        subtitleLabel.setup(with: viewModel?.subtitle)
        subtitleLabel.isHidden = viewModel?.subtitle == nil
        checkmarkImageView.setup(with: viewModel?.checkmark)
        checkmarkImageView.isHidden = viewModel?.checkmark == nil || viewModel?.checkmarkToggle == true
        checkmarkToggleView.isHidden = viewModel?.checkmark == nil || viewModel?.checkmarkToggle == false
    }
    
    @objc func tapped() {
        guard viewModel?.isInteractable == true else { return }
        
        didTap?()
    }
}
