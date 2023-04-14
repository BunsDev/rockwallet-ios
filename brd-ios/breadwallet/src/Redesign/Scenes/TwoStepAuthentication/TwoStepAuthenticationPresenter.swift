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
            .methods
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .instructions: [
                LabelViewModel.text(L10n.TwoStep.mainInstructions)
            ],
            .methods: [
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.email.image),
                                                 title: .text("Email address"),
                                                 subtitle: .text(UserDefaults.email ?? ""),
                                                 checkmark: .image(Asset.radiobutton.image)),
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.pad.image),
                                                 title: .text(L10n.TwoStep.Methods.AuthApp.title),
                                                 checkmark: .image(Asset.radiobuttonSelected.image))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    // MARK: - Additional Helpers
    
}
