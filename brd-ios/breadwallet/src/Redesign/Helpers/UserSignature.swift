// 
//  UserSignature.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 17/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import WalletKit

struct UserSignature {
    func getHeaders(nonce: String?, token: String?) -> [String: String] {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: C.countryUS)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let dateString = formatter.string(from: Date())
        
        guard let nonce = nonce,
              let token = token,
              let data = (dateString + token + nonce).data(using: .utf8)?.sha256,
              let apiKeyString = try? keychainItem(key: KeychainKey.apiAuthKey) as String?,
              !apiKeyString.isEmpty,
              let apiKey = Key.createFromString(asPrivate: apiKeyString),
              let signature = CoreSigner.basicDER.sign(data32: data, using: apiKey)?.base64EncodedString()
        else { return [:] }

        return [
            "Date": dateString,
            "Signature": signature
        ]
    }
}