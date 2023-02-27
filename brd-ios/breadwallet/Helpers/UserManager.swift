// 
//  UserManager.swift
//  breadwallet
//
//  Created by Rok on 22/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class UserManager: NSObject {
    static var shared = UserManager()
    
    var profile: Profile?
    var error: Error?
    var profileResult: Result<Profile?, Error>?
    
    func refresh(completion: ((Result<Profile?, Error>?) -> Void)? = nil) {
        ProfileWorker().execute { [weak self] result in
            self?.profileResult = result
            
            switch result {
            case .success(let profile):
                guard let profile else { return }
                
                UserDefaults.email = profile.email
                
                self?.error = nil
                self?.profile = profile
                
                if profile.status.hasKYC {
                    Store.trigger(name: .didApplyKyc)
                }
                
                Store.trigger(name: .didCreateAccount)
                
            case .failure(let error):
                self?.error = error
                self?.profile = nil
            }
            
            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
    
    func getVeriffSessionUrl(completion: @escaping ((Result<VeriffSession?, Error>?) -> Void)) {
        VeriffSessionWorker().execute { result in
            completion(result)
        }
    }
    
    func setUserCredentials(email: String, sessionToken: String, sessionTokenHash: String) {
        UserDefaults.email = email
        UserDefaults.sessionToken = sessionToken
        UserDefaults.sessionTokenHash = sessionTokenHash
    }
    
    func resetUserCredentials() {
        UserDefaults.email = nil
        UserDefaults.sessionToken = nil
        UserDefaults.sessionTokenHash = nil
        UserDefaults.deviceID = ""
        
        UserManager.shared.profile = nil
        UserManager.shared.profileResult = nil
        UserManager.shared.error = nil
    }
}
