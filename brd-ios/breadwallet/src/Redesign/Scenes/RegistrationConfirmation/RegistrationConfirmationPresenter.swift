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
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let confirmationType = item.type
        let email = item.email ?? ""
        let emailString = ":\n\(email)"
        
        var sections: [Models.Section] = [
            .image,
            .title,
            .instructions,
            .input,
            .help
        ]
        
        // TODO: Check the designs and clean the whole presentData mess.
        
        if confirmationType == .twoStepApp {
            sections = sections.filter({ $0 != .image })
            sections = sections.filter({ $0 != .instructions })
            sections = sections.filter({ $0 != .help })
        }
        
        if confirmationType == .twoStepAppLogin || confirmationType == .twoStepAppResetPassword || confirmationType == .twoStepAppSendFunds {
            sections = sections.filter({ $0 != .image })
            sections = sections.filter({ $0 != .instructions })
        }
        
        if confirmationType == .twoStepAppBackupCode || confirmationType == .twoStepAppBuy {
            sections = sections.filter({ $0 != .image })
        }
        
        let title: String
        let instructions: String
        
        switch confirmationType {
        case .account, .twoStepAccountEmailSettings, .twoStepAccountAppSettings:
            title = L10n.AccountCreation.verifyEmail
            instructions = "\(L10n.AccountCreation.enterCode)\(emailString)"
            
        case .twoStepEmail, .twoStepEmailLogin, .twoStepEmailResetPassword, .twoStepEmailSendFunds, .twoStepEmailBuy, .twoStepDisable:
            title = L10n.TwoStep.Email.Confirmation.title
            instructions = "\(L10n.AccountCreation.enterCode)\(emailString)"
            
        case .twoStepApp, .twoStepAppLogin, .twoStepAppResetPassword, .twoStepAppSendFunds, .twoStepAppBuy:
            title = L10n.TwoStep.App.Confirmation.title
            instructions = ""
        
        case .twoStepAppBackupCode:
            title = L10n.TwoStep.App.Confirmation.BackupCode.title
            instructions = L10n.TwoStep.App.Confirmation.BackupCode.instructions
            
        }
        
        var help: [ButtonViewModel] = [ButtonViewModel(title: L10n.AccountCreation.resendCode,
                                                       isUnderlined: true,
                                                       callback: viewController?.resendCodeTapped)]
        
        if UserManager.shared.profile?.status == .emailPending {
            help.append(ButtonViewModel(title: L10n.AccountCreation.changeEmail,
                                        isUnderlined: true,
                                        callback: viewController?.changeEmailTapped))
        }
        
        if confirmationType == .twoStepAppLogin || confirmationType == .twoStepAppResetPassword || confirmationType == .twoStepAppSendFunds || confirmationType == .twoStepAppBuy {
            help = [ButtonViewModel(title: L10n.TwoStep.App.CantAccess.title,
                                    isUnderlined: true,
                                    callback: viewController?.enterBackupCode)]
        }
        
        if confirmationType == .twoStepAppBackupCode {
            help.removeAll()
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
    
    func presentNextFailure(actionResponse: RegistrationConfirmationModels.NextFailure.ActionResponse) {
        viewController?.displayNextFailure(responseDisplay: .init(reason: actionResponse.reason,
                                                                  registrationRequestData: actionResponse.registrationRequestData))
    }
    
    // MARK: - Additional Helpers

}
