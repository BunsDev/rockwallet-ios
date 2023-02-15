// 
//  LoqateEndpoints.swift
//  breadwallet
//
//  Created by Dino Gacevic on 14/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum LoquateEndpoints: String, URLType {
    static var baseURL: String = "https://api.addressy.com/Capture/Interactive/Find/v1.1/%@"
    
    case base = "json3.ws?Key=%@&Text=%@"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
