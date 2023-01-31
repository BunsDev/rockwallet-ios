//
//  SignUpPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class SignUpPresenter: NSObject, Presenter, SignUpActionResponses {
    
    typealias Models = SignUpModels
    
    weak var viewController: SignUpViewController?
    
    // MARK: - ProfileActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        guard let termsAndConditionsURL = URL(string: C.termsAndConditions) else { return }
        
        let sections: [Models.Section] =  [
            .email,
            .password,
            .confirmPassword,
            .notice,
            .termsTickbox,
            .promotionsTickbox
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .email: [TextFieldModel(title: L10n.Account.enterEmail, value: item.email)],
            .password: [TextFieldModel(title: L10n.Account.enterPassword, value: item.password)],
            .confirmPassword: [TextFieldModel(title: L10n.Account.confirmPassword, value: item.password)],
            .notice: [LabelViewModel.text(L10n.Account.passwordRequirements)],
            .termsTickbox: [TickboxItemViewModel(title: .attributedText(prepareTermsTickboxText()), url: termsAndConditionsURL)],
            .promotionsTickbox: [TickboxItemViewModel(title: .text(L10n.Account.promotionsTickbox))]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: SignUpModels.Validate.ActionResponse) {
        let isValid = actionResponse.isEmailValid &&
        actionResponse.isPasswordValid &&
        actionResponse.isPasswordAgainValid &&
        actionResponse.passwordsMatch &&
        actionResponse.isTermsTickboxValid
        
        let textColor = (actionResponse.passwordState == .error || actionResponse.passwordAgainState == .error) && !isValid ? LightColors.Error.one : LightColors.Text.two
        
        let noticeConfiguration = LabelConfiguration(font: Fonts.Body.three, textColor: textColor)
        
        viewController?.displayValidate(responseDisplay:
                .init(email: actionResponse.email,
                      password: actionResponse.password,
                      passwordAgain: actionResponse.passwordAgain,
                      isEmailValid: actionResponse.isEmailValid,
                      isEmailEmpty: actionResponse.isEmailEmpty,
                      emailModel: .init(title: L10n.Account.enterEmail,
                                        hint: actionResponse.emailState == .error ? "Wrong e-mail address." : nil,
                                        trailing: .image(Asset.warning.image.tinted(with: LightColors.Error.one)),
                                        displayState: actionResponse.emailState),
                      isPasswordValid: actionResponse.isPasswordValid,
                      isPasswordEmpty: actionResponse.isPasswordEmpty,
                      passwordModel: .init(title: L10n.Account.enterPassword,
                                           displayState: actionResponse.passwordState),
                      isPasswordAgainValid: actionResponse.isPasswordAgainValid,
                      isPasswordAgainEmpty: actionResponse.isPasswordAgainEmpty,
                      passwordAgainModel: .init(title: L10n.Account.confirmPassword,
                                                hint: actionResponse.passwordAgainState == .error
                                                && !actionResponse.passwordsMatch ? "Passwords should match." : nil,
                                                displayState: actionResponse.passwordAgainState),
                      isTermsTickboxValid: actionResponse.isTermsTickboxValid,
                      noticeConfiguration: noticeConfiguration,
                      isValid: isValid))
    }
    
    func presentNext(actionResponse: SignUpModels.Next.ActionResponse) {
        viewController?.displayNext(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers
    
    private func prepareTermsTickboxText() -> NSMutableAttributedString {
        let partOneAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: LightColors.Text.two,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.font: Fonts.Body.two]
        let partTwoAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: LightColors.secondary,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font: Fonts.Subtitle.two]
        
        let partOne = NSMutableAttributedString(string: L10n.Account.termsTickbox + " ", attributes: partOneAttributes)
        let partTwo = NSMutableAttributedString(string: L10n.About.terms, attributes: partTwoAttributes)
        let combined = NSMutableAttributedString()
        combined.append(partOne)
        combined.append(partTwo)
        
        return combined
    }
}
