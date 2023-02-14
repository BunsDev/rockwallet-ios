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
        
        let item = Models.Item(items: items, isAddingEnabled: isAddingEnabled)
        presenter?.presentData(actionResponse: .init(item: item))
    }
    
    func search(viewAction: ItemSelectionModels.Search.ViewAction) {
        guard let items = dataStore?.items,
              let searchText = viewAction.text?.lowercased() else { return }
        
        let searchData = searchText.isEmpty ? items : items.filter { $0.displayName?.lowercased().contains(searchText) ?? false }
        let item = Models.Item(items: searchData, isAddingEnabled: dataStore?.isAddingEnabled)
        presenter?.presentData(actionResponse: .init(item: item))
    }
    
    func getPaymentCards(viewAction: BuyModels.PaymentCards.ViewAction) {
        fetchCards { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                guard let items = self.dataStore?.items,
                      let isAddingEnabled = self.dataStore?.isAddingEnabled else { return }
                
                let item = Models.Item(items: items, isAddingEnabled: isAddingEnabled)
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
            presenter?.presentData(actionResponse: .init(item: Models.Item(items: nil, isAddingEnabled: false)))
            return
        }
        
        let request = FindAddressRequestModel(text: input)
        FindAddressWorker().execute(requestData: request) { [weak self] result in
            switch result {
            case .success(let items):
                let item = Models.Item(items: items?.compactMap { AssetViewModel(title: $0.text) }, isAddingEnabled: false)
                self?.presenter?.presentData(actionResponse: .init(item: item))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }        
    }
    
    // MARK: - Aditional helpers
    
    private func fetchCards(completion: ((Result<[PaymentCard]?, Error>) -> Void)?) {
        PaymentCardsWorker().execute(requestData: PaymentCardsRequestData()) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.items = data?.filter { $0.type == .card }
                
            default:
                break
            }
            
            completion?(result)
        }
    }
}

struct FindAddressRequestModel: RequestModelData {
    let text: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "Text": text
        ]
        
        return params.compactMapValues { $0 }
    }
}

class FindAddressWorker: BaseApiWorker<FindAddressMapper> {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? FindAddressRequestModel),
              let text = urlParams.text else {
            return ""
        }
                
        return APIURLHandler.getUrl(LoquateEndpoints.base, parameters: [E.loqateKey, text])
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getDecodingStrategy() -> JSONDecoder.KeyDecodingStrategy {
        return .convertFromPascalCase
    }
}

struct FindAddressResponseData: ModelResponse {
    var items: [FindAddressResponseModel]?
    
    struct FindAddressResponseModel: Codable {
        var text: String?
    }
}

struct FindAddress: Model {
    var text: String?
}

class FindAddressMapper: ModelMapper<FindAddressResponseData, [FindAddress]> {
    override func getModel(from response: FindAddressResponseData?) -> [FindAddress]? {
        return response?.items?.compactMap { .init(text: $0.text)}
    }
}

enum LoquateEndpoints: String, URLType {
    static var baseURL: String = "https://api.addressy.com/Capture/Interactive/Find/v1.1/%@"
    
    case base = "json3.ws?Key=%@&Text=%@"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
