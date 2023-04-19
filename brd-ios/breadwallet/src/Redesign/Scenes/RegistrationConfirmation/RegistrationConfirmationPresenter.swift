//
//  RegistrationConfirmationPresenter.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

final class RegistrationConfirmationPresenter: NSObject, Presenter, RegistrationConfirmationActionResponses {
    typealias Models = RegistrationConfirmationModels

    weak var viewController: RegistrationConfirmationViewController?

    // MARK: - RegistrationConfirmationActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let confirmationType = actionResponse.item as? Models.Item else { return }
        
        let email = "\(": \n")\(UserDefaults.email ?? "")"
        
        var sections: [Models.Section] = [
            .image,
            .title,
            .instructions,
            .input,
            .help
        ]
        
        if confirmationType == .twoStepApp {
            sections = sections.filter({ $0 != .image })
            sections = sections.filter({ $0 != .instructions })
            sections = sections.filter({ $0 != .help })
        }
        
        let title: String
        let instructions: String
        
        switch confirmationType {
        case .account, .acountTwoStepEmailSettings, .acountTwoStepAppSettings:
            title = L10n.AccountCreation.verifyEmail
            instructions = "\(L10n.AccountCreation.enterCode)\(email)"
            
        case .twoStepEmail:
            title = "We’ve sent you a code"
            instructions = "\(L10n.AccountCreation.enterCode)\(email)"
            
        case .twoStepApp, .disable:
            title = "Enter the code from your Authenticator app"
            instructions = ""
            
        }
        
        var help: [ButtonViewModel] = [ButtonViewModel(title: L10n.AccountCreation.resendCode,
                                                       isUnderlined: true)]
        
        if UserManager.shared.profile?.status == .emailPending {
            help.append(ButtonViewModel(title: L10n.AccountCreation.changeEmail, isUnderlined: true))
        }
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .image: [
                ImageViewModel.image(Asset.email.image)
            ],
            .title: [
                LabelViewModel.text(title)
            ],
            .instructions: [
                LabelViewModel.text(instructions)
            ],
            .input: [
                TextFieldModel()
            ],
            .help: [
                MultipleButtonsViewModel(buttons: help)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentConfirm(actionResponse: RegistrationConfirmationModels.Confirm.ActionResponse) {
        viewController?.displayConfirm(responseDisplay: .init())
    }
    
    func presentResend(actionResponse: RegistrationConfirmationModels.Resend.ActionResponse) {
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(L10n.AccountCreation.codeSent)),
                                                              config: Presets.InfoView.verification))
    }
    
    func presentError(actionResponse: RegistrationConfirmationModels.Error.ActionResponse) {
        viewController?.displayError(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers

}
