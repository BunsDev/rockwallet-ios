// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import Foundation

enum KYCEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/one/kyc/%@"
    
    case countriesList = "countries"
    case userInformation = "user-information"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}

enum KYCAuthEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/one/%@"
    
    case newDevice = "auth/new-device"
    case profile = "auth/profile"
    
    case veriffSession = "kyc/session"
    case basic = "kyc/basic"
    case documents = "kyc/documents"
    case upload = "kyc/upload"
    case submit = "kyc/session/submit"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}