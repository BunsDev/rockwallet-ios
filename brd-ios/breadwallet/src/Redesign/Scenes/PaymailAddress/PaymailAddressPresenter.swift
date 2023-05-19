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
        let item = actionResponse.item as? (any Models.Item)
        
        var sections: [Models.Section] = [
            .description,
            .emailViewTitle,
            .emailView,
            .paymail
        ]
        
        if item?.screenType == .paymailSetup {
            sections = sections.filter({ $0 != .emailViewTitle })
        }
        
        let emailValue = item?.paymailAddress != nil ? item?.paymailAddress : Constant.paymailDomain
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .description: [
                LabelViewModel.text(item?.screenType?.description)
            ],
            .emailViewTitle: [
                LabelViewModel.text(L10n.PaymailAddress.createAddressTitle)
            ],
            .emailView: [
                TextFieldModel(title: item?.screenType?.emailViewTitle,
                               value: emailValue,
                               trailing: item?.screenType?.image,
                               isUserInteractionEnabled: item?.screenType == .paymailNotSetup)
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
    
    func presentPaymailSuccess(actionResponse: PaymailAddressModels.CreatePaymail.ActionResponse) {
        viewController?.displayPaymailSuccess(responseDisplay: .init())
    }
    
    func presentSuccessBottomAlert(actionResponse: PaymailAddressModels.BottomAlert.ActionResponse) {
        viewController?.displaySuccessBottomAlert(responseDisplay: .init())
    }
    
    func presentValidate(actionResponse: PaymailAddressModels.Validate.ActionResponse) {
        let isValid = actionResponse.isEmailValid
        
        viewController?.displayValidate(responseDisplay:
                .init(email: actionResponse.email,
                      isEmailValid: actionResponse.isEmailValid,
                      isEmailEmpty: actionResponse.isEmailEmpty,
                      emailModel: .init(title: L10n.PaymailAddress.paymailAddressField,
                                        value: actionResponse.email,
                                        hint: actionResponse.emailState == .error ? L10n.Account.invalidEmail : nil,
                                        trailing: actionResponse.emailState == .error ?
                        .image(Asset.warning.image.tinted(with: LightColors.Error.one)) :
                            .image(Asset.cancel.image.tinted(with: LightColors.Text.three)),
                                        displayState: actionResponse.emailState),
                      isValid: isValid))
    }
    
    // MARK: - Additional Helpers
    
}
