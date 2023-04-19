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
    var profileResult: Result<Profile?, Error>?
    
    var twoStepSettings: TwoStepSettings?
    
    var error: Error?
    
    func refresh(completion: ((Result<Profile?, Error>?) -> Void)? = nil) {
        let group = DispatchGroup()

        group.enter()
        TwoStepSettingsWorker().execute(requestData: TwoStepSettingsRequestData(method: .get, sending: false, achSell: false, buy: false)) { [weak self] result in
            switch result {
            case .success(let data):
                self?.twoStepSettings = data
                
            default:
                break
            }
            
            group.leave()
        }
        
        group.enter()
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
            
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            completion?(self?.profileResult)
        }
    }
    
    func getVeriffSessionUrl(livenessCheckData: VeriffSessionRequestData? = nil, completion: @escaping ((Result<VeriffSession?, Error>?) -> Void)) {
        VeriffSessionWorker().execute(requestData: livenessCheckData) { result in
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
        UserDefaults.phoneNumber = nil
        
        UserManager.shared.profile = nil
        UserManager.shared.profileResult = nil
        UserManager.shared.error = nil
    }
}
