//
//  ItemSelectionInteractor.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

class ItemSelectionInteractor: NSObject, Interactor, ItemSelectionViewActions {
    typealias Models = ItemSelectionModels

    var presenter: ItemSelectionPresenter?
    var dataStore: ItemSelectionStore?

    // MARK: - ItemSelectionViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard let items = dataStore?.items,
              items.isEmpty == false,
              let isAddingEnabled = dataStore?.isAddingEnabled else { return }
        
        let item = Models.Item(items: items, isAddingEnabled: isAddingEnabled, fromCardWithdrawal: dataStore?.fromCardWithdrawal ?? false)
        presenter?.presentData(actionResponse: .init(item: item))
    }
    
    func search(viewAction: ItemSelectionModels.Search.ViewAction) {
        guard let items = dataStore?.items,
              let searchText = viewAction.text?.lowercased() else { return }
        
        let searchData = searchText.isEmpty ? items : items.filter { $0.displayName?.lowercased().contains(searchText) ?? false }
        let item = Models.Item(items: searchData, isAddingEnabled: dataStore?.isAddingEnabled, fromCardWithdrawal: dataStore?.fromCardWithdrawal ?? false)
        presenter?.presentData(actionResponse: .init(item: item))
    }
    
    func getPaymentCards(viewAction: PaymentMethodsModels.PaymentCards.ViewAction) {
        fetchCards { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                guard let items = self.dataStore?.items,
                      let isAddingEnabled = self.dataStore?.isAddingEnabled else { return }
                
                let item = Models.Item(items: items, isAddingEnabled: isAddingEnabled, fromCardWithdrawal: dataStore?.fromCardWithdrawal ?? false)
                self.presenter?.presentData(actionResponse: .init(item: item))
                
            case .failure(let error):
                self.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func showActionSheetRemovePayment(viewAction: ItemSelectionModels.ActionSheet.ViewAction) {
        presenter?.presentActionSheetRemovePayment(actionResponse: .init(instrumentId: viewAction.instrumentId, last4: viewAction.last4))
    }
    
    func removePayment(viewAction: ItemSelectionModels.RemovePayment.ViewAction) {
        DeleteCardWorker().execute(requestData: DeleteCardRequestData(instrumentId: self.dataStore?.instrumentID)) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentRemovePaymentMessage(actionResponse: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func removePaymenetPopup(viewAction: ItemSelectionModels.RemovePaymenetPopup.ViewAction) {
        dataStore?.instrumentID = viewAction.instrumentID
        presenter?.presentRemovePaymentPopup(actionResponse: .init(last4: viewAction.last4))
    }
    
    func findAddress(viewAction: ItemSelectionModels.FindAddress.ViewAction) {
        guard let input = viewAction.input, !input.isEmpty else {
            let fromCardWithdrawal = dataStore?.fromCardWithdrawal ?? false
            presenter?.presentData(actionResponse: .init(item: Models.Item(items: nil, isAddingEnabled: false, fromCardWithdrawal: fromCardWithdrawal)))
            return
        }
        
        let request = FindAddressRequestModel(text: input)
        FindAddressWorker().execute(requestData: request) { [weak self] result in
            switch result {
            case .success(let items):
                let item = Models.Item(items: items, isAddingEnabled: false, fromCardWithdrawal: self?.dataStore?.fromCardWithdrawal ?? false)
                self?.presenter?.presentData(actionResponse: .init(item: item))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }        
    }
    
    // MARK: - Additional helpers
    
    private func fetchCards(completion: ((Result<[PaymentCard]?, Error>) -> Void)?) {
        let worker = dataStore?.fromCardWithdrawal == true ? SellPaymentCardsWorker() : PaymentCardsWorker()
        
        worker.execute(requestData: PaymentCardsRequestData()) { [weak self] result in
            switch result {
            case .success(let data):
                var cards = data?.filter { $0.type == .card }
                if self?.dataStore?.fromCardWithdrawal == true {
                    cards = cards?.filter { $0.scheme == .visa }
                }
                self?.dataStore?.items = cards
                
            default:
                break
            }
            
            completion?(result)
        }
    }
}
