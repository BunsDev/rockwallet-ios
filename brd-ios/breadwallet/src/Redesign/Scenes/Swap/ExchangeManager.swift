// 
//  ExchangeManager.swift
//  breadwallet
//
//  Created by Rok on 23/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class ExchangeManager {
    static let shared = ExchangeManager()
    
    private var worker: ExchangeHistoryWorker
    private var exchanges: [ExchangeDetail]
    
    init() {
        worker = ExchangeHistoryWorker()
        exchanges = []
    }
    
    func reload(for source: String? = nil, completion: (([ExchangeDetail]?) -> Void)? = nil) {
        worker.execute { [weak self] result in
            let exchanges: [ExchangeDetail]
            
            switch result {
            case .success(let data):
                exchanges = data?.sorted(by: { $0.timestamp > $1.timestamp }) ?? []
                
            case .failure:
                exchanges = []
            }
            
            self?.exchanges = exchanges
            
            guard let source = source else {
                completion?(exchanges)
                return
            }
            
            completion?(self?.exchanges.filter { $0.source.currency == source || $0.destination?.currency == source || $0.instantDestination?.currency == source })
        }
    }
    
    func canSwap(_ currency: Currency?) -> Bool {
        return exchanges.first(where: { $0.status == .pending && $0.source.currency == currency?.code }) == nil
    }
}
