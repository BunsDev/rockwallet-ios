// 
//  KYCAuthEndpoints.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 07/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum KYCAuthEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/one/%@"
    
    // TODO: Find better names for the two bio auth endpoints
    case veriffBiometricVerificationSession = "kyc/session?quote_id=%@&is_biometric=%@&biometric_type=%@" // veriff liveness check for buy
    case veriffBiometricVerificationSessionLimits = "kyc/session?is_biometric=%@&biometric_type=%@" // bio auth for limits
    case veriffSession = "kyc/session"
    case longPollBiometricStatus = "kyc/long-poll-biometric-status"
    case basic = "kyc/basic"
    case documents = "kyc/documents"
    case upload = "kyc/upload"
    case submit = "kyc/session/submit"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
