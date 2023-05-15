// 
//  CreateTransactionModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 15/05/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import WalletKit

struct CreateTransactionModels {
    struct Transaction {
        struct ViewAction {
            var exchange: Exchange?
            var currencies: [Currency]?
            var fromFeeBasis: TransferFeeBasis?
            var fromFeeAmount: Amount?
            var fromAmount: Amount?
            var toAmount: Amount?
        }
    }
    
    struct Sender {
        struct ViewAction {
            var fromAmount: Amount?
            var coreSystem: CoreSystem?
            var keyStore: KeyStore?
        }
    }
    
    struct Fee {
        struct ViewAction {}
    }
}
