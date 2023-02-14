// 
//  DynamicLinksManager.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 17/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class DynamicLinksManager {
    static var shared = DynamicLinksManager()
    
    var shouldHandleDynamicLink: Bool {
        return DynamicLinksManager.shared.code != nil
    }
    
    var code: String?
    
    enum DynamicLinkType: String {
        // User Account
        case setPassword = "op=password"
    }
    
    static func getDynamicLinkType(from url: URL) -> DynamicLinkType? {
        if url.absoluteString.contains(DynamicLinkType.setPassword.rawValue) {
            return .setPassword
        }
        
        return nil
    }
    
    static func handleDynamicLink(dynamicLink: URL?) {
        guard let url = dynamicLink else { return }
        
        let dynamicLinkType = DynamicLinksManager.getDynamicLinkType(from: url)
        
        switch dynamicLinkType {
        case .setPassword:
            handleReSetPassword(with: url)
            
        default:
            break
        }
    }
    
    private static func handleReSetPassword(with url: URL) {
        guard let parameters = url.queryParameters,
              let code = parameters["code"] else {
            return
        }
        
        DynamicLinksManager.shared.code = code
    }
}
