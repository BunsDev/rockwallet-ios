//
//  SetPasswordPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class SetPasswordPresenter: NSObject, Presenter, SetPasswordActionResponses {
    
    typealias Models = SetPasswordModels
    
    weak var viewController: SetPasswordViewController?
    
    // MARK: - ProfileActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [Models.Section] =  [
            .password,
            .confirmPassword,
            .notice
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .password: [TextFieldModel(title: L10n.Account.enterPassword, value: item.password)],
            .confirmPassword: [TextFieldModel(title: L10n.Account.confirmPassword, value: item.password)],
            .notice: [LabelViewModel.text(L10n.Account.passwordRequirements)]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: SetPasswordModels.Validate.ActionResponse) {
        viewController?.displayValidate(responseDisplay: .init(isValid: actionResponse.isValid))
    }
    
    func presentNext(actionResponse: SetPasswordModels.Next.ActionResponse) {
        viewController?.displayNext(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers
    
}
