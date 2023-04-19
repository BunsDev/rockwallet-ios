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
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [Models.Section] = [
            .description,
            .emailView,
            .paymail
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .description: [
                LabelViewModel.text(item?.description)
            ],
            .emailView: [
                TextFieldModel(title: item?.emailViewTitle,
                               value: "@rockwallet.io",
                               trailing: .image(item?.image))
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
    
    func presentSuccessBottomAlert(actionResponse: PaymailAddressModels.Success.ActionResponse) {
        viewController?.displaySuccessBottomAlert(responseDisplay: .init())
    }
    
    func presentCopyValue(actionResponse: AuthenticatorAppModels.CopyValue.ActionResponse) {
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(L10n.Receive.copied)),
                                                              config: Presets.InfoView.verification))
    }

    // MARK: - Additional Helpers

}
