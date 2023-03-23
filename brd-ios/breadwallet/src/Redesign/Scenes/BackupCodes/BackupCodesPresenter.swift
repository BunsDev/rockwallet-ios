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
        
        let getCodesButton: [ButtonViewModel] = [ButtonViewModel(title: "Get new codes",
                                                                 isUnderlined: true)]
        
        let sectionRows: [Models.Section: [Any]] = [
            .instructions: [
                LabelViewModel.text("""
Save your backup codes in a secure place. These might be the only way to access your account if you are unable to access your phone or you can’t use your security method
""")
            ],
            .description: [
                LabelViewModel.text("You can use each backup code once, if you’ve already used most of them, you can request a new set of codes.")
            ],
            .getNewCodes: [
                MultipleButtonsViewModel(buttons: getCodesButton)]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
