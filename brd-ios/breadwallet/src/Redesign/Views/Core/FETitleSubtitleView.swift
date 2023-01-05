// 
//  FETitleSubtitleView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct FETitleSubtitleViewConfiguration: Configurable {
    
}

struct FETitleSubtitleViewViewModel: ViewModel {
    var title: LabelViewModel?
    var subtitle: LabelViewModel?
}

class FETitleSubtitleView: FEView<FETitleSubtitleViewConfiguration, FETitleSubtitleViewViewModel> {
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraSmall.rawValue
        view.distribution = .fill
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
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.setupCustomMargins(vertical: .large, horizontal: .huge)
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
    }
    
    override func configure(with config: FETitleSubtitleViewConfiguration?) {
        super.configure(with: config)
        
        titleLabel.configure(with: .init(font: Fonts.Subtitle.two,
                                         textColor: LightColors.Text.three))
        subtitleLabel.configure(with: .init(font: Fonts.Body.two,
                                            textColor: LightColors.Text.two))
        
        configure(background: .init(backgroundColor: LightColors.Background.one,
                                    border: .init(borderWidth: 0,
                                                  cornerRadius: .medium)))
        configure(shadow: Presets.Shadow.light)
    }
    
    override func setup(with viewModel: FETitleSubtitleViewViewModel?) {
        super.setup(with: viewModel)
        guard let viewModel = viewModel else { return }

        titleLabel.setup(with: viewModel.title)
        subtitleLabel.setup(with: viewModel.subtitle)
    }
}
