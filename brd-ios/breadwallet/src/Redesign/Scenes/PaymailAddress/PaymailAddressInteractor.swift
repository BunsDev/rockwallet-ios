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
        presenter?.presentData(actionResponse: .init(item: dataStore?.screenType))
    }
    
    func showPaymailPopup(viewAction: Models.InfoPopup.ViewAction) {
        presenter?.presentPaymailPopup(actionResponse: .init())
    }

    func showSuccessBottomAlert(viewAction: Models.Success.ViewAction) {
        presenter?.presentSuccessBottomAlert(actionResponse: .init())
    }
    
    func getXPub(code: String) -> String {
        var keyStore: KeyStore
        do {
            keyStore = try KeyStore.create()
        } catch { 
            fatalError("error initializing key store")
        }
        let xpub = keyStore.getXPubFromAccount(code: code)
        return xpub
    }
    
    // MARK: - Aditional helpers
}
