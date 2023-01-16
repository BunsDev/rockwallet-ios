//
//  ForgotPasswordPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class ForgotPasswordPresenter: NSObject, Presenter, ForgotPasswordActionResponses {
    
    typealias Models = ForgotPasswordModels
    
    weak var viewController: ForgotPasswordViewController?
    
    // MARK: - ProfileActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? String else { return }
        
        let sections: [Models.Section] =  [
            .notice,
            .email
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .email: [TextFieldModel(title: L10n.Account.email, value: item)],
            .notice: [LabelViewModel.text(L10n.Account.resetPasswordMessage)]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: ForgotPasswordModels.Validate.ActionResponse) {
        viewController?.displayValidate(responseDisplay: .init(isValid: actionResponse.isValid))
    }
    
    // MARK: - Additional Helpers
    
}
