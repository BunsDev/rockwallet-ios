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
    static var shared = ExchangeCurrencyHelper()
    
    var isInExchangeFlow = false {
        willSet(value) {
            if value {
                setUSDifNeeded()
            } else {
                revertIfNeeded()
            }
        }
    }
    
    private func setUSDifNeeded() {
        guard Store.state.defaultCurrencyCode != Constant.usdCurrencyCode else { return }
        
        UserDefaults.temporaryDefaultCurrencyCode = Store.state.defaultCurrencyCode
        
        Store.perform(action: DefaultCurrency.SetDefault(Constant.usdCurrencyCode))
    }
    
    private func revertIfNeeded() {
        guard !UserDefaults.temporaryDefaultCurrencyCode.isEmpty &&
                Store.state.defaultCurrencyCode != UserDefaults.temporaryDefaultCurrencyCode else { return }
        
        Store.perform(action: DefaultCurrency.SetDefault(UserDefaults.temporaryDefaultCurrencyCode))
        
        UserDefaults.temporaryDefaultCurrencyCode = ""
    }
}
