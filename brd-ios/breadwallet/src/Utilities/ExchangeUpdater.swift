//
//  ExchangeUpdater.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-01-27.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import Foundation
// import CoinGecko

enum FiatPriceInfoResult {
    case success([String: FiatPriceInfo])
    case error(String)
}

class ExchangeUpdater: Subscriber {
    
    // MARK: - Public
    
    init() {
        Store.lazySubscribe(self,
                            selector: { $0.defaultCurrencyCode != $1.defaultCurrencyCode },
                            callback: { _ in
            self.refresh()
        })
    }
    
    func refresh() {
        guard !Store.state.currencies.isEmpty else { return }
        fetchPriceInfo(currencies: Store.state.currencies) { result in
            guard case .success(let priceInfo) = result else { return }
            Store.state.currencies.forEach {
                guard let info = priceInfo[$0.coinGeckoId ?? ""] else { return }
                Store.perform(action: WalletChange($0).setFiatPriceInfo(info))
                let fiatCode = Store.state.defaultCurrencyCode
                let rate = Rate(code: fiatCode, name: $0.name, rate: info.price, reciprocalCode: $0.code)
                //Cache result for next launch
                UserDefaults.setCurrentRateData(newValue: rate.dictionary, forCode: $0.code)
                Store.perform(action: WalletChange($0).setExchangeRate(rate))
            }
        }
    }
    
    // MARK: - Private
    
    private let client = CoinGeckoClient()
    
    private func fetchPriceInfo(currencies: [Currency], _ handler: @escaping (FiatPriceInfoResult) -> Void) {
        let chunkSize = 50
        let chunks = currencies.chunked(by: chunkSize)
        var combinedResults: [String: FiatPriceInfo] = [:]
        let group = DispatchGroup()
        for chunk in chunks {
            group.enter()
            let coinGeckoIds = chunk.compactMap { $0.coinGeckoId }
            let vs = Store.state.defaultCurrencyCode.lowercased()
            let resource = Resources.simplePrice(ids: coinGeckoIds, vsCurrency: vs, options: [.change]) { (result: Result<[SimplePrice], CoinGeckoError>) in
                guard case .success(let data) = result else { return group.leave() }
                coinGeckoIds.forEach { id in
                    guard let simplePrice = data.first(where: { $0.id == id }) else { return }
                    let change = simplePrice.change24hr ?? 0.0
                    combinedResults[id] = FiatPriceInfo(changePercentage24Hrs: change,
                                                        change24Hrs: change*simplePrice.price/100,
                                                        price: simplePrice.price)
                }
                group.leave()
            }
            client.load(resource)
        }
        
        group.notify(queue: .main) {
            handler(.success(combinedResults))
        }
    }
    
    private func convert(from: String, to: String, callback: @escaping (Double) -> Void) {
        
        struct FixerResult: Codable {
            var rates: [String: Double]
        }
        
        KeyStore.getFixerApiToken { token in
            guard let token = token else { return }
            let url = URL(string: "http://data.fixer.io/api/latest?access_key=\(token)&base=\(from)&symbols=\(to)")!
            URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
                guard let data = data else { print("error: \(error!)"); return }
                do {
                    let result = try JSONDecoder().decode(FixerResult.self, from: data)
                    if let rate = result.rates[to] {
                        callback(rate)
                    } else {
                        print("Fixer result not found: \(result)")
                    }
                } catch let e {
                    print("JSON decoding error: \(e)")
                }
            }).resume()
        }
    }

}
