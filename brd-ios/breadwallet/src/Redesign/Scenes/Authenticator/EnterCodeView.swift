// 
//  EnterCodeView.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 30.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct EnterCodeViewConfiguration: Configurable {
    var title: LabelConfiguration = .init(font: Fonts.Subtitle.two, textColor: LightColors.Text.three)
    var description: LabelConfiguration = .init(font: Fonts.Body.two, textColor: LightColors.Text.two)
}

struct EnterCodeViewModel: ViewModel {
    var title: LabelViewModel?
    var description: LabelViewModel?
}

class EnterCodeView: FEView<EnterCodeViewConfiguration, EnterCodeViewModel> {
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.huge.rawValue
        return view
    }()
    
    private lazy var topLineView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = LightColors.Outline.one.cgColor
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var descriptionLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        
        mainStack.addArrangedSubview(topLineView)
        topLineView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.minimum.rawValue)
        }
        
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Margins.extraSmall.rawValue)
        }
    }
    
    override func configure(with config: EnterCodeViewConfiguration?) {
        super.configure(with: config)
        
        titleLabel.configure(with: config?.title)
        descriptionLabel.configure(with: config?.description)
    }
    
    override func setup(with viewModel: EnterCodeViewModel?) {
        super.setup(with: viewModel)
        
        titleLabel.setup(with: viewModel?.title)
        descriptionLabel.setup(with: viewModel?.description)
    }
}
    
