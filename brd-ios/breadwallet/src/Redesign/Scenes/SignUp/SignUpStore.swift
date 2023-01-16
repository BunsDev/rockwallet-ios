//
//  SignUpStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SignUpStore: NSObject, BaseDataStore, SignUpDataStore {
    var itemId: String?
    
    // MARK: - ProfileDataStore
    
    var email: String?
    var password: String?
    var passwordAgain: String?
    var termsTickbox: Bool = false
    var promotionsTickbox: Bool = false
    
    // MARK: - Aditional helpers
}
