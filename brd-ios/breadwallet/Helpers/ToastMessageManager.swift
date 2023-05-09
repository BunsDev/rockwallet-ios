// 
//  ToastMessageManager.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 03/05/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class ToastMessageManager {
    static let shared = ToastMessageManager()
    
    private var notification = FEInfoView()
    
    func show(model: InfoViewModel? = nil,
              configuration: InfoViewConfiguration? = nil,
              onTapCallback: (() -> Void)? = nil) {
        guard let activeWindow = UIApplication.shared.activeWindow else { return }
        
        notification.didFinish = { [weak self] in
            self?.hide()
            
            onTapCallback?()
        }
        
        if notification.superview == nil {
            notification.setupCustomMargins(all: .extraLarge)
            notification.configure(with: configuration)
            activeWindow.addSubview(notification)
            notification.alpha = 0
            
            notification.snp.makeConstraints { make in
                make.top.equalTo(activeWindow.safeAreaLayoutGuide.snp.top)
                make.leading.equalToSuperview().offset(Margins.medium.rawValue)
                make.centerX.equalToSuperview()
            }
        }
        
        notification.setup(with: model)
        notification.layoutIfNeeded()
        
        UIView.animate(withDuration: Presets.Animation.short.rawValue) {[weak self] in
            self?.notification.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: Presets.Animation.short.rawValue) { [weak self] in
            self?.notification.alpha = 0
        } completion: { [weak self] _ in
            self?.notification.removeFromSuperview()
        }
    }
}
