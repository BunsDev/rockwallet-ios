//
//  BuyInteractor.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//
//

import UIKit
import WalletKit

class BuyInteractor: NSObject, Interactor, BuyViewActions {
    
    typealias Models = BuyModels
    
    var presenter: BuyPresenter?
    var dataStore: BuyStore?
    
    // MARK: - BuyViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard let currency = dataStore?.toAmount?.currency, dataStore?.supportedCurrencies?.isEmpty != false else { return }
        
        SupportedCurrenciesWorker().execute { [weak self] result in
            switch result {
            case .success(let currencies):
                ExchangeManager.shared.reload()
                
                self?.dataStore?.supportedCurrencies = currencies
                
                self?.fetchCards { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success:
                        self.getExchangeRate(viewAction: .init())
                        self.presenter?.presentData(actionResponse: .init(item: Models.Item(amount: .zero(currency), paymentCard: self.dataStore?.paymentCard)))
                        self.presenter?.presentAssets(actionResponse: .init(amount: self.dataStore?.toAmount,
                                                                            card: self.dataStore?.paymentCard,
                                                                            quote: self.dataStore?.quote,
                                                                            paymentMethod: self.dataStore?.paymentMethod))
                        
                    case .failure(let error):
                        self.presenter?.presentError(actionResponse: .init(error: error))
                    }
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.supportedCurrencies(error: error)))
            }
        }
    }
    
    func getPaymentCards(viewAction: BuyModels.PaymentCards.ViewAction) {
        fetchCards { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                if viewAction.getCards == true {
                    let paymentCards = self.dataStore?.allPaymentCards?.filter { $0.type == .buyCard }
                    self.presenter?.presentPaymentCards(actionResponse: .init(allPaymentCards: paymentCards ?? []))
                } else {
                    self.getExchangeRate(viewAction: .init())
                }
                
            case .failure(let error):
                self.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func getLinkToken(viewAction: BuyModels.PlaidLinkToken.ViewAction) {
        let accountId = dataStore?.paymentCard == nil ? nil : dataStore?.paymentCard?.id
        let requestData = PlaidLinkTokenRequestData(accountId: accountId)
        
        PlaidLinkTokenWorker().execute(requestData: requestData) { [weak self] result in
            switch result {
            case .success(let response):
                guard let linkToken = response?.linkToken else { return }
                self?.presenter?.presentLinkToken(actionResponse: .init(linkToken: linkToken))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func setPublicToken(viewAction: BuyModels.PlaidPublicToken.ViewAction) {
        let accountId = dataStore?.paymentCard == nil ? nil : dataStore?.paymentCard?.id
        PlaidPublicTokenWorker().execute(requestData: PlaidPublicTokenRequestData(publicToken: dataStore?.publicToken,
                                                                                  mask: dataStore?.mask,
                                                                                  accountId: accountId)) { [weak self] result in
            switch result {
            case .success:
                let relinkAchPaymentMethod = self?.dataStore?.relinkAchPaymentMethod ?? false
                self?.presenter?.presentPublicTokenSuccess(actionResponse: .init(relinkAchPaymentMethod: relinkAchPaymentMethod))
                
            case .failure:
                self?.presenter?.presentFailure(actionResponse: .init())
            }
        }
    }
    
    func setAmount(viewAction: BuyModels.Amounts.ViewAction) {
        guard let rate = dataStore?.quote?.exchangeRate,
              let toCurrency = dataStore?.toAmount?.currency else {
            presenter?.presentError(actionResponse: .init(error: ExchangeErrors.noQuote(from: C.usdCurrencyCode,
                                                                                   to: dataStore?.toAmount?.currency.code)))
            return
        }
        
        let to: Amount
        
        dataStore?.values = viewAction
        
        if let value = viewAction.tokenValue,
           let crypto = ExchangeFormatter.current.number(from: value)?.decimalValue {
            to = .init(decimalAmount: crypto, isFiat: false, currency: toCurrency, exchangeRate: 1 / rate)
        } else if let value = viewAction.fiatValue,
                  let fiat = ExchangeFormatter.current.number(from: value)?.decimalValue {
            to = .init(decimalAmount: fiat, isFiat: true, currency: toCurrency, exchangeRate: 1 / rate)
        } else {
            presenter?.presentAssets(actionResponse: .init(amount: dataStore?.toAmount,
                                                           card: dataStore?.paymentCard,
                                                           quote: dataStore?.quote,
                                                           handleErrors: true,
                                                           paymentMethod: dataStore?.paymentMethod))
            return
        }
        
        dataStore?.toAmount = to
        dataStore?.from = to.fiatValue
        
        presenter?.presentAssets(actionResponse: .init(amount: dataStore?.toAmount,
                                                       card: dataStore?.paymentCard,
                                                       quote: dataStore?.quote,
                                                       paymentMethod: dataStore?.paymentMethod))
    }
    
    func setAssets(viewAction: BuyModels.Assets.ViewAction) {
        if let value = viewAction.currency?.lowercased(),
           let currency = Store.state.currencies.first(where: { $0.code.lowercased() == value }) {
            dataStore?.toAmount = .zero(currency)
        } else if let value = viewAction.card {
            dataStore?.paymentCard = value
        }
        
        getExchangeRate(viewAction: .init())
    }
    
    func showOrderPreview(viewAction: BuyModels.OrderPreview.ViewAction) {
        presenter?.presentOrderPreview(actionResponse: .init())
    }
    
    func navigateAssetSelector(viewAction: BuyModels.AssetSelector.ViewAction) {
        presenter?.presentNavigateAssetSelector(actionResponse: .init())
    }
    
    // MARK: - Aditional helpers
    
    private func fetchCards(completion: ((Result<[PaymentCard]?, Error>) -> Void)?) {
        PaymentCardsWorker().execute(requestData: PaymentCardsRequestData()) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.allPaymentCards = data
                
                if self?.dataStore?.autoSelectDefaultPaymentMethod == true {
                    let paymentCards: [PaymentCard]?
                    
                    switch self?.dataStore?.paymentMethod {
                    case .buyAch:
                        paymentCards = self?.dataStore?.allPaymentCards?.filter { $0.type == .buyAch }
                        
                    default:
                        paymentCards = self?.dataStore?.allPaymentCards?.filter { $0.type == .buyCard }
                    }
                    
                    self?.dataStore?.paymentCard = paymentCards?.first
                }
                
                self?.dataStore?.autoSelectDefaultPaymentMethod = true
                
            default:
                break
            }
            
            completion?(result)
        }
    }
    
    func selectPaymentMethod(viewAction: BuyModels.PaymentMethod.ViewAction) {
        let currency = Store.state.currencies.first(where: { $0.code == C.USDC })
        guard viewAction.method == .buyAch, currency == nil else {
            dataStore?.paymentMethod = viewAction.method
            var paymentCards: [PaymentCard]?
            
            switch dataStore?.paymentMethod {
            case .buyAch:
                if let currency = Store.state.currencies.first(where: { $0.code == C.USDC }) {
                    dataStore?.toAmount = .zero(currency)
                }
                paymentCards = dataStore?.allPaymentCards?.filter { $0.type == .buyAch }
                
            default:
                if let currency = Store.state.currencies.first(where: { $0.code == C.BTC }) ?? Store.state.currencies.first {
                    dataStore?.toAmount = .zero(currency)
                }
                paymentCards = dataStore?.allPaymentCards?.filter { $0.type == .buyCard }
            }
            
            if dataStore?.autoSelectDefaultPaymentMethod == true {
                dataStore?.paymentCard = paymentCards?.first
            }
            
            let model = dataStore?.values ?? .init()
            setAmount(viewAction: model)
            getExchangeRate(viewAction: .init())
            
            return
        }
        
        presenter?.presentUSDCMessage(actionResponse: .init())
    }
}
