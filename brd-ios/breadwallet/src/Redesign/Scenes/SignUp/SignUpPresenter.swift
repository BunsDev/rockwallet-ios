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
        viewController?.displayValidate(responseDisplay: .init(isEmailValid: actionResponse.isEmailValid,
                                                               isPasswordValid: actionResponse.isPasswordValid,
                                                               isTermsTickboxValid: actionResponse.isTermsTickboxValid))
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
