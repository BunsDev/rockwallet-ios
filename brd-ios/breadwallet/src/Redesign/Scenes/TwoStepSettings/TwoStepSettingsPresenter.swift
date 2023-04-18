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
            .description: [LabelViewModel.text(L10n.TwoStep.preferredSettings)],
            .settings: [
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.signInIntoNewDevice),
                                                 subtitle: .text(L10n.TwoStep.mandatory),
                                                 checkmark: .image(Asset.checkboxSelectedCircle.image)),
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.recoverChangingPassword),
                                                 subtitle: .text(L10n.TwoStep.mandatory),
                                                 checkmark: .image(Asset.checkboxSelectedCircle.image)),
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.twoStepPeriod),
                                                 subtitle: .text(L10n.TwoStep.mandatory),
                                                 checkmark: .image(Asset.checkboxSelectedCircle.image)),
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.sendingFunds), checkmarkToggle: true),
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.buyTransactions), checkmarkToggle: true)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
