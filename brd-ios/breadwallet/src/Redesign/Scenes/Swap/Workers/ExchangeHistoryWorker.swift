// 
//  SwapHistoryWorker.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 25.7.22.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct ExchangeDetailsExchangesResponseData: ModelResponse {
    var exchanges: [ExchangeDetailsResponseData]
}

class SwapHistoryMapper: ModelMapper<ExchangeDetailsExchangesResponseData, [SwapDetail]> {
    override func getModel(from response: ExchangeDetailsExchangesResponseData?) -> [SwapDetail] {
        var exchanges = (response?.exchanges ?? []).compactMap { ExchangeDetailsMapper().getModel(from: $0) }
        
        for exchange in exchanges where exchange.instantDestination?.transactionId != nil {
            var one = exchange
            one.part = .one
            
            var two = exchange
            two.part = .two
            
            exchanges.insert(one, at: 0)
            exchanges.insert(two, at: 0)
            
            exchanges = exchanges.filter { $0 != exchange }
        }
        
        return exchanges
    }
}

class SwapHistoryWorker: BaseApiWorker<SwapHistoryMapper> {
    override func getUrl() -> String {
        return ExchangeEndpoints.history.url
    }
}
