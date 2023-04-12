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
                LabelViewModel.text("Your Paymail address is setted up. Share your Paymail address instead of your wallet address to receive funds seamlessly.")
            ],
            .emailView: [
                LabelViewModel.text("Your Paymail address:")
            ],
            .paymail: [
                MultipleButtonsViewModel(buttons: [ButtonViewModel(title: "What is Paymail?",
                                                                   isUnderlined: true)])]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentPaymailPopup(actionResponse: PaymailAddressModels.InfoPopup.ActionResponse) {
        let model: PopupViewModel = .init(title: .text("What is Paymail?"),
                                          body: """
Paymail is a collection of protocols for Bitcoin SV wallets that allow for a set of simplified user experiences to be delivered across all wallets in the ecosystem.
The goals of the paymail protocol are:
User friendly payment destinations through memorable handles
""")
        
        viewController?.displayPaymailPopup(responseDisplay: .init(model: model))
    }

    // MARK: - Additional Helpers

}
