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
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .password: [TextFieldModel(title: L10n.Account.enterPassword, value: item.password)],
            .confirmPassword: [TextFieldModel(title: L10n.Account.confirmPassword, value: item.password)],
            .notice: [LabelViewModel.text(L10n.Account.passwordRequirements)]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: SetPasswordModels.Validate.ActionResponse) {
        let isValid = actionResponse.isPasswordValid &&
        actionResponse.isPasswordAgainValid &&
        actionResponse.passwordsMatch
        
        let textColor = (actionResponse.passwordState == .error || actionResponse.passwordAgainState == .error) && !isValid ? LightColors.Error.one : LightColors.Text.two
        
        let noticeConfiguration = LabelConfiguration(font: Fonts.Body.three, textColor: textColor)
        
        viewController?.displayValidate(responseDisplay:
                .init(password: actionResponse.password,
                      passwordAgain: actionResponse.passwordAgain,
                      isPasswordValid: actionResponse.isPasswordValid,
                      isPasswordEmpty: actionResponse.isPasswordEmpty,
                      passwordModel: .init(title: L10n.Account.enterPassword,
                                           hint: !actionResponse.passwordsMatch && !actionResponse.isPasswordEmpty
                                           && !actionResponse.isPasswordAgainEmpty ? L10n.Account.passwordDoNotMatch : nil,
                                           trailing: !actionResponse.passwordsMatch && !actionResponse.isPasswordEmpty
                                           && !actionResponse.isPasswordAgainEmpty ? .image(Asset.warning.image.tinted(with: LightColors.Error.one)) : nil,
                                           displayState: actionResponse.passwordState),
                      isPasswordAgainValid: actionResponse.isPasswordAgainValid,
                      isPasswordAgainEmpty: actionResponse.isPasswordAgainEmpty,
                      passwordAgainModel: .init(title: L10n.Account.confirmPassword,
                                                hint: !actionResponse.passwordsMatch && !actionResponse.isPasswordEmpty
                                                && !actionResponse.isPasswordAgainEmpty ? L10n.Account.passwordDoNotMatch : nil,
                                                trailing: !actionResponse.passwordsMatch && !actionResponse.isPasswordEmpty
                                                && !actionResponse.isPasswordAgainEmpty ? .image(Asset.warning.image.tinted(with: LightColors.Error.one)) : nil,
                                                displayState: actionResponse.passwordAgainState),
                      noticeConfiguration: noticeConfiguration,
                      isValid: isValid))
    }
    
    func presentNext(actionResponse: SetPasswordModels.Next.ActionResponse) {
        viewController?.displayNext(responseDisplay: .init())
    }
    
    func presentNextFailure(actionResponse: SetPasswordModels.NextFailure.ActionResponse) {
        viewController?.displayNextFailure(responseDisplay: .init(reason: actionResponse.reason,
                                                                  setPasswordRequestData: actionResponse.setPasswordRequestData))
    }
    
    // MARK: - Additional Helpers
    
}
