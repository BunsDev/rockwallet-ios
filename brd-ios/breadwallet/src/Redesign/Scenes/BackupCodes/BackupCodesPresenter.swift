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
            .backupCodes,
            .description,
            .getNewCodes
        ]
        
        let backupCodes: [LabelViewModel] = [LabelViewModel.text("123 456"),
                                              LabelViewModel.text("695 456"),
                                              LabelViewModel.text("123 789"),
                                              LabelViewModel.text("789 456"),
                                              LabelViewModel.text("654 456")] // TODO: Update with BE codes
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .instructions: [
                LabelViewModel.text(L10n.BackupCodes.instructions)
            ],
            .backupCodes: [
                BackupCodesViewModel(backupCodes: backupCodes)
            ],
            .description: [
                LabelViewModel.text(L10n.BackupCodes.description)
            ],
            .getNewCodes: [
                MultipleButtonsViewModel(buttons: [ButtonViewModel(title: L10n.BackupCodes.getNewCodes,
                                                                   isUnderlined: true)])]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
