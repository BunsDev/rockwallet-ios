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
        if let item = actionResponse.item as? Models.Item { return }
        
        let sections: [Models.Section] = [
            .instructions,
            .methods,
            .additionalMethods,
            .settingsTitle,
            .settings
        ]
        
        let changeNumberString = NSAttributedString(string: "Change Phone Number",
                                                    attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        let methodsText = NSMutableAttributedString(string: "Additional methods" + " ")
        methodsText.addAttribute(NSAttributedString.Key.font,
                                 value: Fonts.Body.two,
                                 range: NSRange(location: 0, length: methodsText.length))
        methodsText.addAttribute(NSAttributedString.Key.foregroundColor,
                                 value: LightColors.Text.two,
                                 range: NSRange(location: 0, length: methodsText.length))
        
        let interactableText = NSMutableAttributedString(string: "Get your backup codes")
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
                LabelViewModel.text("Select you preferred authentication method")
            ],
            .methods: [
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.phone.image),
                                                 title: .text("Phone number XX-XXXX-9400"),
                                                 subtitle: .attributedText(changeNumberString),
                                                 checkmark: .image(Asset.radiobutton.image)),
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.pad.image),
                                                 title: .text("Authentication app"),
                                                 checkmark: .image(Asset.radiobuttonSelected.image))
            ],
            .additionalMethods: [
                LabelViewModel.attributedText(methodsText)
            ],
            .settingsTitle: [
                LabelViewModel.text("Settings")
            ],
            .settings: [
                IconTitleSubtitleToggleViewModel(title: .text("Authentication app"),
                                                 checkmark: .image(Asset.check.image)),
                IconTitleSubtitleToggleViewModel(title: .text("Recover/Changing password"),
                                                 checkmark: .image(Asset.check.image)),
                IconTitleSubtitleToggleViewModel(title: .text("Every 90 days"),
                                                 checkmark: .image(Asset.check.image)),
                IconTitleSubtitleToggleViewModel(title: .text("Sending funds"),
                                                 checkmarkToggle: true),
                IconTitleSubtitleToggleViewModel(title: .text("ACH Withdrawal"),
                                                 checkmarkToggle: true),
                IconTitleSubtitleToggleViewModel(title: .text("Buy transactions"),
                                                 checkmarkToggle: true)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    // MARK: - Additional Helpers
    
}
