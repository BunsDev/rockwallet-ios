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
            var string = string
            string.insert(" ", at: string.index(string.startIndex, offsetBy: 2))
            return LabelViewModel.text(string)
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
    
    // MARK: - Additional Helpers

}
