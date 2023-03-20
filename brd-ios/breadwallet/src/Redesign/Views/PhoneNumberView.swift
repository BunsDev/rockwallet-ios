// 
//  PhoneNumberView.swift
//  breadwallet
//
//  Created by Kanan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct PhoneNumberConfiguration: Configurable {
}

struct PhoneNumberViewModel: ViewModel {
    var areaCode: TextFieldModel?
    var phoneNumber: TextFieldModel?
}

class PhoneNumberView: FEView<PhoneNumberConfiguration, PhoneNumberViewModel>, StateDisplayable {
    var didPresentPicker: (() -> Void)?
    var displayState: DisplayState = .normal
    
    private lazy var areaCodeTextfield: FETextField = {
        let view = FETextField()
        return view
    }()
    
    private lazy var phoneNumberTextField: FETextField = {
        let view = FETextField()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(phoneNumberTextField)
        content.addSubview(areaCodeTextfield)
        
        areaCodeTextfield.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        
        phoneNumberTextField.snp.makeConstraints { make in
            make.top.bottom.equalTo(areaCodeTextfield)
            make.trailing.equalToSuperview()
            make.leading.equalTo(areaCodeTextfield.snp.trailing).inset(Margins.minimum.rawValue)
        }
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(triggerPresentPicker)))
    }
    
    override func configure(with config: PhoneNumberConfiguration?) {
        super.configure(with: config)
        
        var areaCodePreset = Presets.TextField.primary
        areaCodePreset.backgroundConfiguration?.border?.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        areaCodeTextfield.configure(with: areaCodePreset)
        
        var phoneNumberPreset = Presets.TextField.primary
        phoneNumberPreset.keyboardType = .numberPad
        phoneNumberPreset.backgroundConfiguration?.border?.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        phoneNumberTextField.configure(with: phoneNumberPreset)
    }
    
    override func setup(with viewModel: PhoneNumberViewModel?) {
        super.setup(with: viewModel)
        
        var areaCode = viewModel?.areaCode
        areaCode?.isUserInteractionEnabled = false
        
        areaCodeTextfield.setup(with: areaCode)
        phoneNumberTextField.setup(with: viewModel?.phoneNumber)
        
        animateTo(state: .normal)
    }
    
    @objc private func triggerPresentPicker() {
        didPresentPicker?()
        
        animateTo(state: .selected)
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        let background: BackgroundConfiguration?
        
        switch state {
        case .normal:
            background = Presets.TextField.primary.backgroundConfiguration
            
        default:
            background = Presets.TextField.primary.selectedBackgroundConfiguration
        }
        
        displayState = state
        
        areaCodeTextfield.configure(background: background)
    }
}
