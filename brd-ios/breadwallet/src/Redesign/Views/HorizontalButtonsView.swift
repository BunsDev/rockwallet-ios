// 
//  HorizontalButtonsView.swift
//  breadwallet
//
//  Created by Rok on 03/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct HorizontalButtonsConfiguration: Configurable {
    var background: BackgroundConfiguration?
    var buttons: [ButtonConfiguration] = []
    var isRightAligned = false
    var isDoubleButtonStack = false
}

struct HorizontalButtonsViewModel: ViewModel {
    var buttons: [ButtonViewModel] = []
}

class HorizontalButtonsView: FEView<HorizontalButtonsConfiguration, HorizontalButtonsViewModel> {
    var callbacks: [(() -> Void)] = []
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()
    
    private var buttons: [FEButton] = []
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.setupClearMargins()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(ViewSizes.Common.largeCommon.rawValue)
        }
    }
    
    override func configure(with config: HorizontalButtonsConfiguration?) {
        super.configure(with: config)
        
        configure(background: config?.background)
        
        setupButtons()
    }
    
    private func setupButtons() {
        guard let viewModel = viewModel, let config = config else { return }
        
        buttons = []
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, model) in viewModel.buttons.enumerated() {
            let button = FEButton()
            
            var buttonConfig: ButtonConfiguration?
            if index < config.buttons.count {
                buttonConfig = config.buttons[index]
            } else {
                buttonConfig = config.buttons.last
            }
            
            button.configure(with: buttonConfig)
            button.setup(with: model)
            
            buttons.append(button)
            stack.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        if config.isDoubleButtonStack {
            stack.distribution = .fillProportionally
            stack.spacing = Margins.medium.rawValue
        } else {
            stack.distribution = .fill
            stack.spacing = Margins.huge.rawValue
            
            let spacer = UIView()
            stack.insertArrangedSubview(spacer, at: config.isRightAligned ? 0 : stack.arrangedSubviews.endIndex)
            
            spacer.snp.makeConstraints { make in
                make.width.greaterThanOrEqualToSuperview().priority(.low)
            }
        }
        
        stack.layoutIfNeeded()
    }
    
    // MARK: - User interaction
    @objc private  func buttonTapped(_ sender: UIButton) {
        guard let index = buttons.firstIndex(where: { $0 == sender }) else { return }
        
        if index >= callbacks.count {
            callbacks.last?()
        } else {
            callbacks[index]()
        }
    }
}
