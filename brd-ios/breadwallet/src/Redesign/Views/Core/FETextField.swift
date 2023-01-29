//
//  FETextField.swift
//  breadwallet
//
//  Created by Rok on 11/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct TextFieldConfiguration: Configurable {
    var leadingImageConfiguration: BackgroundConfiguration?
    var titleConfiguration: LabelConfiguration?
    var selectedTitleConfiguration: LabelConfiguration?
    var textConfiguration: LabelConfiguration?
    var placeholderConfiguration: LabelConfiguration?
    var hintConfiguration: LabelConfiguration?
    
    var trailingImageConfiguration: BackgroundConfiguration?
    var backgroundConfiguration: BackgroundConfiguration?
    var selectedBackgroundConfiguration: BackgroundConfiguration?
    var disabledBackgroundConfiguration: BackgroundConfiguration?
    var errorBackgroundConfiguration: BackgroundConfiguration?
    
    var shadow: ShadowConfiguration?
    var background: BackgroundConfiguration?
    
    var autocapitalizationType: UITextAutocapitalizationType = .none
    var autocorrectionType: UITextAutocorrectionType = .no
    var keyboardType: UIKeyboardType = .default
    var isSecureTextEntry: Bool = false
}

extension TextFieldConfiguration {
    func setSecure(_ isSecure: Bool) -> TextFieldConfiguration {
        var copy = self
        copy.isSecureTextEntry = isSecure
        return copy
    }
}

struct TextFieldModel: ViewModel {
    var leading: ImageViewModel?
    var title: String?
    var value: String?
    var placeholder: String?
    var hint: String?
    var info: InfoViewModel?
    var trailing: ImageViewModel?
    var displayState: DisplayState?
    var displayStateAnimated: Bool?
}

class FETextField: FEView<TextFieldConfiguration, TextFieldModel>, UITextFieldDelegate, StateDisplayable {
    // TODO: displayState is unused. Remove later.
    var displayState: DisplayState = .normal
    
    var valueChanged: ((UITextField) -> Void)?
    var beganEditing: ((UITextField) -> Void)?
    var finishedEditing: ((UITextField) -> Void)?
    var triggered: ((UITextField) -> Void)?
    
    var didTapTrailingView: (() -> Void)?
    var didPasteText: ((String) -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isUserInteractionEnabled = true
    }
    
    override var isUserInteractionEnabled: Bool {
        get {
            return textField.isUserInteractionEnabled
        }
        
        set {
            content.isUserInteractionEnabled = newValue
            textField.isUserInteractionEnabled = newValue
        }
    }
    
    var hideTitleForState: DisplayState?
    
    var value: String? {
        get { return textField.text }
        set {
            textField.text = newValue
        }
    }
    
    // MARK: Lazy UI
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var textFieldContent: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var textFieldStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = -Margins.medium.rawValue
        return view
    }()
    
    private lazy var titleStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = Margins.small.rawValue
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var hintLabel: FELabel = {
        let view = FELabel()
        view.isHidden = true
        return view
    }()
    
    private lazy var leadingView: FEImageView = {
        let view = FEImageView()
        return view
    }()
    
    private lazy var textField: UITextField = {
        let view = UITextField()
        view.isHidden = true
        return view
    }()
    
    private lazy var trailingView: FEImageView = {
        let view = FEImageView()
        return view
    }()
    
    var delegate: UITextFieldDelegate?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(textFieldContent)
        mainStack.addArrangedSubview(hintLabel)
        
        textFieldContent.addSubview(textFieldStack)
        textFieldContent.addSubview(trailingView)
        
        textFieldStack.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.Common.defaultCommon.rawValue)
            make.leading.equalTo(Margins.large.rawValue)
            make.trailing.equalTo(trailingView.snp.leading).offset(-Margins.minimum.rawValue)
            make.top.equalToSuperview()
        }
        
        textFieldStack.addArrangedSubview(titleStack)
        titleStack.addArrangedSubview(leadingView)
        titleStack.addArrangedSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().priority(.low)
        }
        
        trailingView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.height.equalTo(textFieldStack.snp.height)
            make.width.equalTo(ViewSizes.extraSmall.rawValue)
            make.trailing.equalTo(-Margins.large.rawValue)
            make.centerY.equalToSuperview()
        }
        
        textFieldStack.addArrangedSubview(textField)
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = delegate ?? self
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(startEditing))
        addGestureRecognizer(tapped)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(trailingViewTapped))
        trailingView.isUserInteractionEnabled = true
        trailingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func configure(with config: TextFieldConfiguration?) {
        guard let config = config else { return }
        
        super.configure(with: config)
        
        textField.autocapitalizationType = config.autocapitalizationType
        textField.autocorrectionType = config.autocorrectionType
        textField.keyboardType = config.keyboardType
        textField.isSecureTextEntry = config.isSecureTextEntry
        
        if let textConfig = config.textConfiguration {
            textField.font = textConfig.font
            textField.textColor = textConfig.textColor
            textField.textAlignment = textConfig.textAlignment
        }
        
        leadingView.configure(with: config.leadingImageConfiguration)
        trailingView.configure(with: config.trailingImageConfiguration)
        
        shadowView = mainStack
        backgroundView = textFieldContent
        
        configure(background: config.background)
        configure(shadow: config.shadow)
    }
    
    override func setup(with viewModel: TextFieldModel?) {
        guard let viewModel = viewModel else { return }
        
        super.setup(with: viewModel)
        
        titleLabel.setup(with: .text(viewModel.title))
        titleLabel.isHidden = viewModel.title == nil
        textField.text = viewModel.value
        
        if let placeholder = viewModel.placeholder,
           let config = config?.placeholderConfiguration {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: (config.textColor ?? .black),
                .font: config.font
            ]
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
        
        hintLabel.setup(with: .text(viewModel.hint))
        
        leadingView.setup(with: viewModel.leading)
        leadingView.isHidden = viewModel.leading == nil
        
        trailingView.setup(with: viewModel.trailing)
        trailingView.isHidden = viewModel.trailing == nil
        trailingView.snp.updateConstraints { make in
            make.width.equalTo(viewModel.trailing == nil ? 0 : ViewSizes.extraSmall.rawValue)
        }
        
        titleStack.isHidden = leadingView.isHidden && trailingView.isHidden && titleLabel.isHidden
        
        animateTo(state: viewModel.displayState ?? .normal, withAnimation: viewModel.displayStateAnimated == true)
    }
    
    func update(with viewModel: TextFieldModel) {
        self.viewModel = TextFieldModel(leading: viewModel.leading,
                                        title: viewModel.title,
                                        value: textField.text,
                                        placeholder: viewModel.placeholder,
                                        hint: viewModel.hint,
                                        info: viewModel.info,
                                        trailing: viewModel.trailing,
                                        displayState: viewModel.displayState,
                                        displayStateAnimated: true)
        
        setup(with: self.viewModel)
    }
    
    @objc private func startEditing() {
        textField.becomeFirstResponder()
        
        animateTo(state: .selected, withAnimation: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        beganEditing?(textField)
        triggered?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateTo(state: .normal, withAnimation: true)
        
        finishedEditing?(textField)
        triggered?(textField)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        valueChanged?(textField)
        triggered?(textField)
    }
    
    @objc func trailingViewTapped() {
        didTapTrailingView?()
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        let state = state != .error && textField.isFirstResponder == false ? .normal : state
        
        viewModel?.displayState = state
        
        let background: BackgroundConfiguration?
        
        let hint = viewModel?.hint
        var hideTextField = textField.text?.isEmpty == true
        let titleStackCurrentState = titleStack.isHidden
        var titleConfig: LabelConfiguration? = config?.titleConfiguration
        
        switch state {
        case .normal:
            background = config?.backgroundConfiguration
            titleConfig = config?.titleConfiguration
            
        case .highlighted, .selected, .filled:
            background = config?.selectedBackgroundConfiguration
            titleConfig = config?.selectedTitleConfiguration
            
            hideTextField = false
            
        case .disabled:
            background = config?.disabledBackgroundConfiguration
            
        case .error:
            background = config?.errorBackgroundConfiguration
            
            hideTextField = false
        }
        
        hintLabel.setup(with: .text(hint))
        
        titleLabel.configure(with: titleConfig)
        hintLabel.configure(with: .init(textColor: background?.tintColor))
        configure(background: background)
        
        UIView.setAnimationsEnabled(withAnimation)
        
        Self.animate(withDuration: Presets.Animation.short.rawValue) { [weak self] in
            self?.titleStack.isHidden = self?.hideTitleForState == state || titleStackCurrentState
            self?.textField.isHidden = hideTextField
            self?.hintLabel.isHidden = self?.hintLabel.text.isNilOrEmpty == true
        }
        
        UIView.setAnimationsEnabled(true)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard E.isDebug || E.isTestFlight else { return true }
        if string.count > 1,
           string.count == UIPasteboard.general.string?.count,
           let didPasteText = didPasteText {
            didPasteText(string)
            return false
        }
        return true
    }
}
