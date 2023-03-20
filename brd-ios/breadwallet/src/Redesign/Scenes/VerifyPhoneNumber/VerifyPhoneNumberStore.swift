//
//  VerifyPhoneNumberStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class VerifyPhoneNumberStore: NSObject, BaseDataStore, VerifyPhoneNumberDataStore {
    // MARK: - VerifyPhoneNumberDataStore
    
    var itemId: String?
    var code: String?
    
    // MARK: - Aditional helpers
}
