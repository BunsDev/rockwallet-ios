//
//  PaymailAddressInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.4.23.
//
//

import UIKit

class PaymailAddressInteractor: NSObject, Interactor, PaymailAddressViewActions {
    typealias Models = PaymailAddressModels

    var presenter: PaymailAddressPresenter?
    var dataStore: PaymailAddressStore?

    // MARK: - PaymailAddressViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item(dataStore?.screenType ?? .paymailNotSetup)))
    }
    
    func showPaymailPopup(viewAction: Models.InfoPopup.ViewAction) {
        presenter?.presentPaymailPopup(actionResponse: .init())
    }

    func showSuccessBottomAlert(viewAction: Models.Success.ViewAction) {
        presenter?.presentSuccessBottomAlert(actionResponse: .init())
    }
    
    func copyValue(viewAction: AuthenticatorAppModels.CopyValue.ViewAction) {
        let value = viewAction.value?.filter { !$0.isWhitespace } ?? ""
        UIPasteboard.general.string = value
        
        presenter?.presentCopyValue(actionResponse: .init())
    }
    
    // MARK: - Aditional helpers
}
