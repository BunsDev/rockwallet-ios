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
        let screenType = actionResponse.item as? PaymailAddressModels.ScreenType
        
        var sections: [Models.Section] = [
            .description,
            .emailViewTitle,
            .emailView,
            .paymail
        ]
        
        if screenType == .paymailSetup {
            sections = sections.filter({ $0 != .emailViewTitle })
        }
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .description: [
                LabelViewModel.text(screenType?.description)
            ],
            .emailViewTitle: [
                LabelViewModel.text(L10n.PaymailAddress.createAddressTitle)
            ],
            .emailView: [
                TextFieldModel(title: screenType?.emailViewTitle,
                               value: Constant.paymailDomain,
                               trailing: .image(screenType?.image))
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

    // MARK: - Additional Helpers

}
