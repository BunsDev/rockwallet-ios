//
//  ExchangeDetailsInteractor.swift
//  breadwallet
//
//  Created by Rok on 06/07/2022.
//
//

import UIKit

class ExchangeDetailsInteractor: NSObject, Interactor, ExchangeDetailsViewActions {
    typealias Models = ExchangeDetailsModels

    var presenter: ExchangeDetailsPresenter?
    var dataStore: ExchangeDetailsStore?
    
    // MARK: - ExchangeDetailsViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard let itemId = dataStore?.exchangeId, !itemId.isEmpty else { return }
        
        let data = ExchangeDetailsRequestData(exchangeId: itemId)
        ExchangeDetailsWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                guard let data = data, let transactionType = self?.dataStore?.transactionType else { return }
                let item = ExchangeDetailsModels.Item(detail: data, type: transactionType)
                self?.presenter?.presentData(actionResponse: .init(item: item))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func showInfoPopup(viewAction: ExchangeDetailsModels.InfoPopup.ViewAction) {
        presenter?.presentInfoPopup(actionResponse: .init())
    }
    
    // MARK: - Additional helpers
}
