// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit

class VerifyAccountInteractor: NSObject, Interactor, VerifyAccountViewActions {
    typealias Models = VerifyAccountModels

    var presenter: VerifyAccountPresenter?
    var dataStore: VerifyAccountStore?

    // MARK: - VerifyAccountViewActions

    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item(coverImageName: dataStore?.coverImageName,
                                                                       subtitleMessage: dataStore?.subtitleMessage)))
    }
    
    // MARK: - Aditional helpers
}
