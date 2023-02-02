//
//  ForgotPasswordStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class ForgotPasswordStore: NSObject, BaseDataStore, ForgotPasswordDataStore {
    var itemId: String?
    
    // MARK: - ProfileDataStore
    
    var email: String = ""
    
    // MARK: - Aditional helpers
}
