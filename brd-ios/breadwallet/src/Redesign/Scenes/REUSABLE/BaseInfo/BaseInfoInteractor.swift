//
//  BaseInfoInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 13.7.22.
//
//

import UIKit

class BaseInfoInteractor: NSObject, Interactor, BaseInfoViewActions {
    
    typealias Models = BaseInfoModels

    var presenter: BaseInfoPresenter?
    var dataStore: BaseInfoStore?
    
    // MARK: - SwapInfoViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: nil))
    }
    
    func getAssetSelectionData(viewModel: BaseInfoModels.Assets.ViewAction) {
        SupportedCurrenciesWorker().execute { [weak self] result in
            switch result {
            case .success(let currencies):
                ExchangeManager.shared.reload()
                
                self?.presenter?.presentAssetSelectionData(actionResponse: .init(supportedCurrencies: currencies))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.supportedCurrencies(error: error)))
            }
        }
    }

    // MARK: - Aditional helpers
}
