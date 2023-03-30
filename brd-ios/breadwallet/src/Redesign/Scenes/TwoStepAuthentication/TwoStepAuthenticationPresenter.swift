//
//  TwoStepAuthenticationPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 27/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class TwoStepAuthenticationPresenter: NSObject, Presenter, TwoStepAuthenticationActionResponses {
    typealias Models = TwoStepAuthenticationModels
    
    weak var viewController: TwoStepAuthenticationViewController?
    
    // MARK: - TwoStepAuthenticationActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Section] = [
            .instructions,
            .methods,
            .additionalMethods,
            .settingsTitle,
            .settings
        ]
        
        let changeNumberString = NSAttributedString(string: L10n.TwoStep.Methods.Phone.subtitle,
                                                    attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        let methodsText = NSMutableAttributedString(string: L10n.TwoStep.additionalMethodsTitle + " ")
        methodsText.addAttribute(NSAttributedString.Key.font,
                                 value: Fonts.Body.two,
                                 range: NSRange(location: 0, length: methodsText.length))
        methodsText.addAttribute(NSAttributedString.Key.foregroundColor,
                                 value: LightColors.Text.two,
                                 range: NSRange(location: 0, length: methodsText.length))
        
        let interactableText = NSMutableAttributedString(string: L10n.TwoStep.getBackupCodesTitle)
        interactableText.addAttribute(NSAttributedString.Key.font,
                                      value: Fonts.Subtitle.two,
                                      range: NSRange(location: 0, length: interactableText.length))
        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: LightColors.secondary,
            NSAttributedString.Key.underlineColor: LightColors.secondary,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        interactableText.addAttributes(linkAttributes, range: NSRange(location: 0, length: interactableText.length))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        methodsText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: methodsText.length))
        
        methodsText.append(interactableText)
        
        let sectionRows: [Models.Section: [Any]] = [
            .instructions: [
                LabelViewModel.text(L10n.TwoStep.mainInstructions + " " + "")
            ],
            .methods: [
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.phone.image),
                                                 title: .text(L10n.TwoStep.Methods.Phone.title + " " + "000000000"),
                                                 subtitle: .attributedText(changeNumberString),
                                                 checkmark: .image(Asset.radiobutton.image)),
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.pad.image),
                                                 title: .text(L10n.TwoStep.Methods.AuthApp.title),
                                                 checkmark: .image(Asset.radiobuttonSelected.image))
            ],
            .additionalMethods: [
                LabelViewModel.attributedText(methodsText)
            ],
            .settingsTitle: [
                LabelViewModel.text(L10n.Button.settings)
            ],
            .settings: [
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.Settings.signInNewDevice),
                                                 checkmark: .image(Asset.check.image)),
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.Settings.recoverChangePassword),
                                                 checkmark: .image(Asset.check.image)),
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.Settings.everyNinetyDays),
                                                 checkmark: .image(Asset.check.image)),
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.Settings.funds),
                                                 checkmarkToggle: true),
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.Settings.achWithdrawal),
                                                 checkmarkToggle: true),
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.Settings.buyTransactions),
                                                 checkmarkToggle: true)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    // MARK: - Additional Helpers
    
}
