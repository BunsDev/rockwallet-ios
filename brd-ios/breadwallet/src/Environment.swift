//
//  Environment.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-06-20.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

// swiftlint:disable type_name

/// Environment Flags
struct E {
    static var isIPhone5: Bool {
        #if IS_EXTENSION_ENVIRONMENT
        return false
        #else
        let bounds = UIApplication.shared.activeWindow?.bounds
        return bounds?.width == 320 && bounds?.height == 568
        #endif
    }
    
    static var isIPhone6: Bool {
        #if IS_EXTENSION_ENVIRONMENT
        return false
        #else
        let bounds = UIApplication.shared.activeWindow?.bounds
        return bounds?.width == 375 && bounds?.height == 667
        #endif
    }
    
    static let isIPhoneX: Bool = {
        #if IS_EXTENSION_ENVIRONMENT
        return false
        #else
        return (UIScreen.main.bounds.size.height == 812.0) || (UIScreen.main.bounds.size.height == 896.0)
        #endif
    }()
    
    static var isIPhone6OrSmaller: Bool {
        #if IS_EXTENSION_ENVIRONMENT
        return false
        #else
        return isIPhone6 || isIPhone5
        #endif
    }
    
    static var isSmallScreen: Bool {
        #if IS_EXTENSION_ENVIRONMENT
        return false
        #else
        let bounds = UIApplication.shared.activeWindow?.bounds
        return bounds?.width == 320
        #endif
    }
    
    static var apiUrl: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String,
              !url.isEmpty else {
            return fail()
        }
        return url
    }
    
    static var apiToken: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "API_TOKEN") as? String,
              !token.isEmpty else {
            return fail()
        }
        return token
    }
    
    static var checkoutApiToken: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "CHECKOUT_API_TOKEN") as? String,
              !token.isEmpty else {
            return fail()
        }
        return token
    }
    
    static var loqateKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "LOQATE_KEY") as? String, !key.isEmpty else { return fail() }
        return key
    }
    
    static let isTestnet: Bool = {
        #if TESTNET
            return true
        #else
            return false
        #endif
    }()
    
    static let isTestFlight: Bool = {
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }()
    
    static let isSimulator: Bool = {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }()
    
    static let isDebug: Bool = {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()
    
    static let isRunningTests: Bool = {
        #if DEBUG
            return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        #else
            return false
        #endif
    }()
    
    static var isProduction: Bool {
        return Bundle.main.object(forInfoDictionaryKey: "IS_PRODUCTION") as? String == "true"
    }
    
    static var isDevelopment: Bool {
        return Bundle.main.object(forInfoDictionaryKey: "IS_DEVELOPMENT") as? String == "true"
    }
    
    static var isStaging: Bool {
        return Bundle.main.object(forInfoDictionaryKey: "IS_STAGING") as? String == "true"
    }
    
    static var isLdt: Bool {
        return Bundle.main.object(forInfoDictionaryKey: "IS_LDT") as? String == "true"
    }
    
    static func fail() -> String {
        fatalError("Env not configured properly")
    }
}
