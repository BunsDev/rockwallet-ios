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
    
    enum DynamicLinkType: String {
        case setPassword = "op=password"
        case unknown
    }
    
    private static func getDynamicLinkType(from url: String) -> DynamicLinkType {
        if url.contains(DynamicLinkType.setPassword.rawValue) {
            return .setPassword
        }
        
        return .unknown
    }
    
    static func handleDynamicLink(on coordinator: BaseCoordinator?, dynamicLink: URL?) {
        guard let url = dynamicLink else { return }
        
        let dynamicLinkType = DynamicLinksManager.getDynamicLinkType(from: url.absoluteString)
        
        switch dynamicLinkType {
        case .setPassword:
            handleReSetPassword(on: coordinator, dynamicLinkType: dynamicLinkType, with: url)
            
        case .unknown:
            break
        }
    }
    
    private static func handleReSetPassword(on coordinator: BaseCoordinator?, dynamicLinkType: DynamicLinkType, with url: URL) {
        guard let parameters = url.getQueryParameters(),
              let code = parameters["code"],
              let guid = parameters["guid"] else {
            return
        }
        
        coordinator?.openModally(coordinator: AccountCoordinator.self, scene: Scenes.SetPassword) { vc in
            vc?.dataStore?.code = code
            vc?.dataStore?.guid = guid
        }
    }
}

extension URL {
    func getQueryParameters() -> [String: String]? {
        var results = [String: String]()
        
        guard let keyValues = query?.components(separatedBy: "&") else { return nil }
        
        if keyValues.isEmpty == false {
            for pair in keyValues {
                let kv = pair.components(separatedBy: "=")
                
                if kv.count > 1 {
                    results.updateValue(kv[1].removingPercentEncoding ?? kv[1], forKey: kv[0])
                }
            }
        }
        
        return results
    }
}
