// 
//  SupportedCurrenciesManager.swift
//  breadwallet
//
//  Created by Dino Gacevic on 24/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class SupportedCurrenciesManager {
    static let shared = SupportedCurrenciesManager()
    
    var supportedCurrencies: [SupportedCurrency] = []
    
    func getSupportedCurrencies(completion: (() -> Void)?) {
        SupportedCurrenciesWorker().execute { [weak self] result in
            switch result {
            case .success(let currencies):
                self?.supportedCurrencies = currencies ?? []
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            completion?()
        }
    }
}
