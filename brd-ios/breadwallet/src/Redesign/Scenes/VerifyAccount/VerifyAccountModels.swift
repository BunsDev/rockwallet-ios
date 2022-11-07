// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit
import SwiftUI

enum VerifyAccountModels {
    typealias Item = (coverImageName: String?, subtitleMessage: String?)
    
    enum Section: Sectionable {
        case image
        case title
        case description
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
}
