// 
//  AssetModels.swift
//  breadwallet
//
//  Created by Rok on 09/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import WalletKit

enum AssetModels {
    enum Asset {
        struct ViewAction {
            var fiatValue: String? = "0"
            var tokenValue: String? = "0"
            
            var currency: String?
            var card: PaymentCard?
        }
        
        struct ActionResponse {
            var fromAmount: Amount?
            var toAmount: Amount?
            
            var card: PaymentCard?
            var type: PaymentCard.PaymentType?
            
            var fromFee: Amount?
            var toFee: Amount?
            
            var senderValidationResult: SenderValidationResult?
            var fromFeeBasis: TransferFeeBasis?
            var fromFeeAmount: Amount?
            var fromFeeCurrency: Currency?
            var quote: Quote?
            
            var handleErrors = false
        }
    }
    
    enum ExchangeRate {
        struct ViewAction {
            var getFees: Bool = false
        }
        
        struct ActionResponse {
            var quote: Quote?
            var from: String?
            var to: String?
            var limits: NSMutableAttributedString?
            var showTimer: Bool?
            var isFromBuy: Bool?
        }
        
        struct ResponseDisplay {
            var rateAndTimer: ExchangeRateViewModel?
            var accountLimits: LabelViewModel?
        }
    }
    enum CoingeckoRate {
        struct ViewAction {
            var getFees: Bool = false
        }
    }
}
