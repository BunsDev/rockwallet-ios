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
        if let item = actionResponse.item as? Models.Item {
            return
        }
        
        let sections: [Models.Section] = [
            .instructions,
            .description,
            .getNewCodes
        ]
        
        let getCodesButton: [ButtonViewModel] = [ButtonViewModel(title: L10n.BackupCodes.getNewCodes,
                                                                 isUnderlined: true)]
        
        let sectionRows: [Models.Section: [Any]] = [
            .instructions: [
                LabelViewModel.text(L10n.BackupCodes.instructions)
            ],
            .description: [
                LabelViewModel.text(L10n.BackupCodes.description)
            ],
            .getNewCodes: [
                MultipleButtonsViewModel(buttons: getCodesButton)]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
