//
//  TwoStepSettingsPresenter.swift
//  breadwallet
//
//  Created by Dino Gacevic on 17/04/2023.
//
//

import UIKit

final class TwoStepSettingsPresenter: NSObject, Presenter, TwoStepSettingsActionResponses {
    typealias Models = TwoStepSettingsModels

    weak var viewController: TwoStepSettingsViewController?

    // MARK: - TwoStepSettingsActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Section] = [
            .description,
            .settings
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .description: [LabelViewModel.text("Select your preferred 2FA settings")],
            .settings: [
                IconTitleSubtitleToggleViewModel(title: .text("Sign in into new device"),
                                                 subtitle: .text("(Mandatory)"),
                                                 checkmark: .image(Asset.checkboxSelectedCircle.image)),
                IconTitleSubtitleToggleViewModel(title: .text("Recover/Changing password"),
                                                 subtitle: .text("(Mandatory)"),
                                                 checkmark: .image(Asset.checkboxSelectedCircle.image)),
                IconTitleSubtitleToggleViewModel(title: .text("Every 90 days"),
                                                 subtitle: .text("(Mandatory)"),
                                                 checkmark: .image(Asset.checkboxSelectedCircle.image)),
                IconTitleSubtitleToggleViewModel(title: .text("Sending funds"), checkmarkToggle: true),
                IconTitleSubtitleToggleViewModel(title: .text("Buy transactions"), checkmarkToggle: true)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
