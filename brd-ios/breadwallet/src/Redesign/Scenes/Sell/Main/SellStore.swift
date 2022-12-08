//
//  SellStore.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

class SellStore: NSObject, BaseDataStore, SellDataStore {
    // MARK: - SellDataStore
    
    var currency: Currency?
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    // MARK: - Aditional helpers
}
