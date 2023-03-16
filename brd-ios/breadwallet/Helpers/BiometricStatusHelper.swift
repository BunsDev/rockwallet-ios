// 
//  BiometricStatusHelper.swift
//  breadwallet
//
//  Created by Dino Gacevic on 14/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class BiometricStatusHelper {
    static var shared = BiometricStatusHelper()
    
    private var biometricStatusRetryCounter: Int = 0
    
    func checkBiometricStatus(resetCounter: Bool, completion: ((Error?) -> Void)?) {
        if resetCounter {
            biometricStatusRetryCounter = 5
        }
        biometricStatusRetryCounter -= 1
        
        BiometricStatusWorker().execute(requestData: BiometricStatusRequestData(quoteId: nil)) { [weak self] result in
            switch result {
            case .success(let data):
                guard let self = self, let status = data?.status else { return }
                
                switch status {
                case .approved:
                    completion?(nil)
                    
                case .submitted, .started: // Case .started might not be needed in the future.
                    guard self.biometricStatusRetryCounter >= 0 else {
                        completion?(GeneralError())
                        return
                    }
                    
                    self.checkBiometricStatus(resetCounter: false, completion: completion)
                    
                default:
                    completion?(GeneralError())
                }
                
            case .failure:
                completion?(GeneralError())
            }
        }
    }
}
