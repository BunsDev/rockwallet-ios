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
        return DynamicLinksManager.shared.dynamicLinkType != nil
    }
    
    enum DynamicLinkType: String {
        case setPassword = "op=password"
        case home = "home"
        case profile = "profile"
        case swap = "swap"
    }
    
    var dynamicLinkType: DynamicLinkType?
    var code: String?
    
    static func getDynamicLinkType(from url: URL) -> DynamicLinkType? {
        let url = url.absoluteString
        
        if url.contains(DynamicLinkType.setPassword.rawValue) {
            return .setPassword
        } else if url.contains(DynamicLinkType.home.rawValue) {
            return .home
        } else if url.contains(DynamicLinkType.profile.rawValue) {
            return .profile
        } else if url.contains(DynamicLinkType.swap.rawValue) {
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
            DynamicLinksManager.shared.dynamicLinkType = .home
            
        case .profile:
            DynamicLinksManager.shared.dynamicLinkType = .profile
            
        case .swap:
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
