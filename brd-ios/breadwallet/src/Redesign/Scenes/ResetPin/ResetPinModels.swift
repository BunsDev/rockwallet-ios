// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit

enum ResetPinModels {
    
    enum Section: Sectionable {
        case title
        case image
        case button
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
}
