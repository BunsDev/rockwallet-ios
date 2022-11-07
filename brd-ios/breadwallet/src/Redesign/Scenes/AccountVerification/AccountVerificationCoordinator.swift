// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit

class AccountVerificationCoordinator: BaseCoordinator, AccountVerificationRoutes {
    // MARK: - AccountVerificationRoutes
    
    func showKYCBasic() {
        open(scene: Scenes.KYCBasic)
    }

    // MARK: - Aditional helpers
}
