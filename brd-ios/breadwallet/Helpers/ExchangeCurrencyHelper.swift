// 
//  ExchangeCurrencyHelper.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 23/09/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct ExchangeCurrencyHelper {
    static func setUSDifNeeded(completion: (() -> Void)) {
        guard Store.state.defaultCurrencyCode != Constant.usdCurrencyCode else {
            completion()
            
            return
        }
        
        UserDefaults.temporaryDefaultCurrencyCode = Store.state.defaultCurrencyCode
        
        Store.perform(action: DefaultCurrency.SetDefault(Constant.usdCurrencyCode))
        
        completion()
    }
    
    static func revertIfNeeded(coordinator: CoordinatableRoutes? = nil, completion: (() -> Void)? = nil) {
        if let coordinator = coordinator {
            guard coordinator.isKind(of: ExchangeCoordinator.self) else {
                completion?()
                
                return
            }
        }
        
        guard UserDefaults.temporaryDefaultCurrencyCode.isEmpty == false &&
                Store.state.defaultCurrencyCode != UserDefaults.temporaryDefaultCurrencyCode else {
            completion?()
            
            return
        }
        
        Store.perform(action: DefaultCurrency.SetDefault(UserDefaults.temporaryDefaultCurrencyCode))
        
        UserDefaults.temporaryDefaultCurrencyCode = ""
        
        completion?()
    }
}
