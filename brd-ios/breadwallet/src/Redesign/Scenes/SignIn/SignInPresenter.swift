//
//  SignInPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class SignInPresenter: NSObject, Presenter, SignInActionResponses {
    
    typealias Models = SignInModels
    
    weak var viewController: SignInViewController?
    
    // MARK: - ProfileActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [Models.Section] =  [
            .email,
            .password,
            .forgotPassword
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .email: [TextFieldModel(title: L10n.Account.enterEmail, value: item.email)],
            .password: [TextFieldModel(title: L10n.Account.enterPassword, value: item.password)],
            .forgotPassword: [ScrollableButtonsViewModel(buttons: [ButtonViewModel(title: L10n.Account.forgotPassword,
                                                                                   isUnderlined: true)])]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    // MARK: - Additional Helpers
    
}
