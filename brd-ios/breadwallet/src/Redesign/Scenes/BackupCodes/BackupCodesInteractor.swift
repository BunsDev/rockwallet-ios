//
//  BackupCodesInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 23.3.23.
//
//

import UIKit

class BackupCodesInteractor: NSObject, Interactor, BackupCodesViewActions {
    typealias Models = BackupCodesModels

    var presenter: BackupCodesPresenter?
    var dataStore: BackupCodesStore?

    // MARK: - BackupCodesViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: nil))
    }

    // MARK: - Aditional helpers
}
