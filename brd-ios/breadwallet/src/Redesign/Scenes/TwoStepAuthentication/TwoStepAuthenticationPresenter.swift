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
        let authType = actionResponse.item as? TwoStepSettingsResponseData.TwoStepType?
        
        var sections: [Models.Section] = [
            .email,
            .app
        ]
        
        let authExists = authType != nil
        
        var authMethodDescription: String?
        if authType == .email {
            authMethodDescription = "Two Factor Authentication in enabled with Email"
        } else if authType == .authenticator {
            authMethodDescription = "Two Factor Authentication in enabled with Authenticator App"
        }
        
        let isTwoStepEnabled = authExists ? LabelViewModel.text(authMethodDescription) : nil
        let emailAuthCheckmark = authType == .email ? Asset.radiobuttonSelected.image : Asset.radiobutton.image
        let appAuthCheckmark = authType == .authenticator ? Asset.radiobuttonSelected.image : Asset.radiobutton.image
        
        if authExists {
            sections.insert(.instructions, at: 0)
        }
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .instructions: [
                isTwoStepEnabled
            ],
            .email: [
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.mail.image),
                                                 title: .text("Email address"),
                                                 subtitle: .text(UserDefaults.email ?? ""),
                                                 checkmark: .image(emailAuthCheckmark))
            ],
            .app: [
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.phone.image),
                                                 title: .text(L10n.TwoStep.Methods.AuthApp.title),
                                                 checkmark: .image(appAuthCheckmark))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    // MARK: - Additional Helpers
    
}
