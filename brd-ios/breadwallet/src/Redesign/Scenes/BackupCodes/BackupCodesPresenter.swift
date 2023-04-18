//
//  BackupCodesPresenter.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 23.3.23.
//
//

import UIKit

final class BackupCodesPresenter: NSObject, Presenter, BackupCodesActionResponses {
    typealias Models = BackupCodesModels

    weak var viewController: BackupCodesViewController?

    // MARK: - BackupCodesActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Section] = [
            .instructions,
            .getNewCodes,
            .backupCodes
        ]
        
        let backupCodes: [LabelViewModel] = (actionResponse.item as? [String])?.compactMap({ string in
            return LabelViewModel.text(string.separated(stride: 3))
        }) ?? []
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .instructions: [
                LabelViewModel.text(L10n.BackupCodes.instructions)
            ],
            .getNewCodes: [
                MultipleButtonsViewModel(buttons: [ButtonViewModel(title: L10n.BackupCodes.getNewCodes,
                                                                   isUnderlined: true)])],
            .backupCodes: [
                BackupCodesViewModel(backupCodes: backupCodes)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentSkipSaving(actionResponse: BackupCodesModels.SkipBackupCodeSaving.ActionResponse) {
        let popupViewModel = PopupViewModel(title: .text("Important note"),
                                            body: """
Your backup codes are the only way to to
access your account if you loose access your Authenticator App
""",
                                            buttons: [.init(title: "I understand")],
                                            closeButton: .init(image: Asset.close.image))
        
        viewController?.displaySkipSaving(responseDisplay: .init(popupViewModel: popupViewModel,
                                                                    popupConfig: Presets.Popup.whiteCentered))
    }
    
    // MARK: - Additional Helpers

}
