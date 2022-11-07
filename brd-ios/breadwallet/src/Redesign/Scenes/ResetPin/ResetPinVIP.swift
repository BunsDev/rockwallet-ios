// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit

extension Scenes {
    static let ResetPin = ResetPinViewController.self
}

protocol ResetPinViewActions: BaseViewActions, FetchViewActions {
}

protocol ResetPinActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol ResetPinResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol ResetPinDataStore: BaseDataStore, FetchDataStore {
}

protocol ResetPinDataPassing {
    var dataStore: ResetPinDataStore? { get }
}

protocol ResetPinRoutes: CoordinatableRoutes {
}
