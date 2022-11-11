// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit

class AccountVerificationStore: NSObject, BaseDataStore, AccountVerificationDataStore {
    
    var itemId: String?
    var verificationStatus: VerificationStatus?
    var profile: Profile?
    
    // MARK: - AccountVerificationDataStore

    // MARK: - Aditional helpers
}
