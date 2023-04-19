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
        guard let settings = actionResponse.item as? TwoStepSettings else { return }
        
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
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.sendingFunds),
                                                 checkmarkToggleState: settings.sending,
                                                 checkmarkToggle: true),
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.buyTransactions),
                                                 checkmarkToggleState: settings.buy,
                                                 checkmarkToggle: true)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
