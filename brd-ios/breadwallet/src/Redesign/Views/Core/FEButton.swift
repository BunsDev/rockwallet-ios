// 
//  FEButton.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

// TODO: refactor to use apples button configurations
struct ButtonConfiguration: Configurable {
    var normalConfiguration: BackgroundConfiguration?
    var selectedConfiguration: BackgroundConfiguration?
    var disabledConfiguration: BackgroundConfiguration?
    var shadowConfiguration: ShadowConfiguration?
    var buttonContentEdgeInsets = UIEdgeInsets(top: Margins.medium.rawValue,
                                               left: Margins.huge.rawValue,
                                               bottom: Margins.medium.rawValue,
                                               right: Margins.huge.rawValue)
    
    func withBorder(normal: BorderConfiguration? = nil,
                    selected: BorderConfiguration? = nil,
                    disabled: BorderConfiguration? = nil) -> ButtonConfiguration {
        var copy = self
        copy.normalConfiguration?.border = normal
        copy.selectedConfiguration?.border = selected
        copy.disabledConfiguration?.border = disabled
        return copy
    }
}

struct ButtonViewModel: ViewModel {
    var title: String?
    var isUnderlined = false
    // update to UIImage
    var image: UIImage?
    var enabled = true
    var callback: (() -> Void)?
}

class FEButton: UIButton, ViewProtocol, StateDisplayable, Borderable, Shadable {
    var displayState: DisplayState = .normal
    
    var config: ButtonConfiguration?
    var viewModel: ButtonViewModel?
    
    override var isSelected: Bool {
        didSet {
            guard isEnabled else { return }
            animateTo(state: isSelected ? .selected : .normal)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard isEnabled else { return }
            animateTo(state: isHighlighted ? .highlighted : .normal)
        }   
    }
    
    override var isEnabled: Bool {
        didSet {
            animateTo(state: isEnabled ? .normal : .disabled, withAnimation: false)
        }
    }
    
    lazy var shadowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    required override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        layer.insertSublayer(shadowLayer, below: layer)
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        animateTo(state: displayState, withAnimation: false)
    }
    
    func configure(with config: ButtonConfiguration?) {
        guard let config = config else { return }
        
        self.config = config
        contentEdgeInsets = config.buttonContentEdgeInsets
        setTitleColor(config.normalConfiguration?.tintColor, for: .normal)
        setTitleColor(config.disabledConfiguration?.tintColor, for: .disabled)
        setTitleColor(config.selectedConfiguration?.tintColor, for: .selected)
        setTitleColor(config.selectedConfiguration?.tintColor, for: .highlighted)
        titleLabel?.font = Fonts.button
        
        layoutIfNeeded()
    }
    
    func setup(with viewModel: ButtonViewModel?) {
        guard let viewModel = viewModel else { return }

        self.viewModel = viewModel
        
        if let title = viewModel.isUnderlined ? viewModel.title : viewModel.title?.uppercased() {
            if viewModel.isUnderlined {
                let attributeString = NSMutableAttributedString(
                    string: title,
                    attributes: [
                        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
                    ]
                )
                setAttributedTitle(attributeString, for: .normal)
            } else {
                setTitle(title, for: .normal)
            }
        }
        
        if let image = viewModel.image {
            if viewModel.title == nil {
                setBackgroundImage(image, for: .normal)
            } else {
                imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
                titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
                setImage(image, for: .normal)
            }
        }
        
        isEnabled = viewModel.enabled
    }
    
    @objc private func buttonTapped() {
        viewModel?.callback?()
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        let background: BackgroundConfiguration?
        let shadow = config?.shadowConfiguration
        
        switch state {
        case .normal:
            background = config?.normalConfiguration

        case .highlighted, .selected:
            background = config?.selectedConfiguration

        case .disabled:
            background = config?.disabledConfiguration

        case .error, .filled:
            background = nil
        }
        
        displayState = state
        
        UIView.setAnimationsEnabled(withAnimation)
        Self.animate(withDuration: Presets.Animation.short.rawValue) { [weak self] in
            self?.updateLayout(background: background, shadow: shadow)
        }
        UIView.setAnimationsEnabled(true)
    }
    
    private func updateLayout(background: BackgroundConfiguration?, shadow: ShadowConfiguration?) {
        configure(background: background)
        configure(shadow: shadow)
    }
    
    func configure(shadow: ShadowConfiguration?) {
        guard let shadow = shadow else { return }
        
        shadowLayer.setShadow(with: shadow)
    }
    
    func configure(background: BackgroundConfiguration?) {
        guard let background = background else { return }

        tintColor = background.tintColor
        titleLabel?.textColor = background.tintColor
        imageView?.tintColor = background.tintColor
        
        setBackground(with: background)
    }
}
