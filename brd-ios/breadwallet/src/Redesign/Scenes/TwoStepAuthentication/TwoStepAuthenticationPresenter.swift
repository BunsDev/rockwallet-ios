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
        var sections: [Models.Section] = [
            .methods
        ]
        
        let isTwoStepEnabled = Bool.random() ? LabelViewModel.text(L10n.TwoStep.mainInstructions) : nil
        if let isTwoStepEnabled {
            sections.insert(.instructions, at: 0)
        }
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .instructions: [
                isTwoStepEnabled
            ],
            .methods: [
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.mail.image),
                                                 title: .text("Email address"),
                                                 subtitle: .text(UserDefaults.email ?? ""),
                                                 checkmark: .image(Asset.radiobutton.image)),
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.phone.image),
                                                 title: .text(L10n.TwoStep.Methods.AuthApp.title),
                                                 checkmark: .image(Asset.radiobutton.image))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    // MARK: - Additional Helpers
    
}
