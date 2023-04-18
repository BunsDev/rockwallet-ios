//
//  PaymailAddressPresenter.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.4.23.
//
//

import UIKit

final class PaymailAddressPresenter: NSObject, Presenter, PaymailAddressActionResponses {
    typealias Models = PaymailAddressModels

    weak var viewController: PaymailAddressViewController?

    // MARK: - PaymailAddressActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Section] = [
            .description,
            .emailView,
            .paymail
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .description: [
                LabelViewModel.text(L10n.PaymailAddress.description)
            ],
            .emailView: [
                TextFieldModel(title: "Create your paymail", value: "@rockwallet.io")
            ],
            .paymail: [
                MultipleButtonsViewModel(buttons: [ButtonViewModel(title: L10n.PaymailAddress.whatIsPaymail,
                                                                   isUnderlined: true)])]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentPaymailPopup(actionResponse: PaymailAddressModels.InfoPopup.ActionResponse) {
        let model: PopupViewModel = .init(title: .text(L10n.PaymailAddress.whatIsPaymail),
                                          body: L10n.PaymailAddress.popupDescription)
        
        viewController?.displayPaymailPopup(responseDisplay: .init(model: model))
    }

    // MARK: - Additional Helpers

}
