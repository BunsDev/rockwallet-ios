//
//  TwoStepSettingsInteractor.swift
//  breadwallet
//
//  Created by Dino Gacevic on 17/04/2023.
//
//

import UIKit

class TwoStepSettingsInteractor: NSObject, Interactor, TwoStepSettingsViewActions {
    typealias Models = TwoStepSettingsModels

    var presenter: TwoStepSettingsPresenter?
    var dataStore: TwoStepSettingsStore?

    // MARK: - TwoStepSettingsViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: nil))
    }

    // MARK: - Aditional helpers
}
