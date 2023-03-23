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
    
    enum DynamicLinkType: String {
        // User Account
        case setPassword = "op=password"
        case home = "home"
        case profile = "profile"
        case swap = "swap"
    }
    
    var dynamicLinkType: DynamicLinkType?
    var code: String?
    
    static func getDynamicLinkType(from url: URL) -> DynamicLinkType? {
        if url.absoluteString.contains(DynamicLinkType.setPassword.rawValue) {
            return .setPassword
        } else if url.absoluteString.contains(DynamicLinkType.home.rawValue) {
            return .home
        } else if url.absoluteString.contains(DynamicLinkType.profile.rawValue) {
            return .profile
        } else if url.absoluteString.contains(DynamicLinkType.swap.rawValue) {
            return .swap
        }
        
        return nil
    }
    
    static func handleDynamicLink(dynamicLink: URL?) {
        guard let url = dynamicLink else { return }
        
        let dynamicLinkType = DynamicLinksManager.getDynamicLinkType(from: url)
        
        switch dynamicLinkType {
        case .setPassword:
            handleReSetPassword(with: url)
            
        case .home:
            // TODO: In future handle parameters
            DynamicLinksManager.shared.dynamicLinkType = .home
            
        case .profile:
            // TODO: In future handle parameters
            DynamicLinksManager.shared.dynamicLinkType = .profile
            
        case .swap:
            // TODO: In future handle parameters
            DynamicLinksManager.shared.dynamicLinkType = .swap
            
        default:
            break
        }
    }
    
    private static func handleReSetPassword(with url: URL) {
        guard let parameters = url.queryParameters,
              let code = parameters["code"] else {
            return
        }
        
        DynamicLinksManager.shared.dynamicLinkType = .setPassword
        DynamicLinksManager.shared.code = code
    }
}
