//
//  SellModels.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

enum SellModels {
    typealias Item = Currency
    
    struct Amounts {
        struct ViewAction {
            var from: String?
            var to: String?
        }
        
        struct ActionResponse {
            var from: Amount?
            var continueEnabled: Bool = false
        }
    }
    
    struct PaymentMethod {
        struct ViewAction {}
        
        struct ActionResponse {
            var from: Amount?
        }
        
        struct ResponseDisplay {
            var continueEnabled = false
            var amounts: MainSwapViewModel
        }
    }
}
