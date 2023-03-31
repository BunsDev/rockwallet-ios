// 
//  CoinGeckoTests.swift
//  breadwalletTests
//
//  Created by Adrian Corscadden on 2020-07-14.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import XCTest
@testable import breadwallet
// import CoinGecko

private var authenticator: WalletAuthenticator { return keyStore as WalletAuthenticator }
private var brClient: BRAPIClient!
private var keyStore: KeyStore!
private let exchangeUpdate = ExchangeUpdater()

class CoinGeckoTests : XCTestCase {
    
    private let fiatCurrencies = CurrencyFileManager.getCurrencyMetaDataFromCache(type: .fiatCurrencies)
    private let coinGeckoClient = CoinGeckoClient()
    
    override class func setUp() {
        super.setUp()
        clearKeychain()
        keyStore = try! KeyStore.create()
        _ = setupNewAccount(keyStore: keyStore) // each test will get its own account
        brClient = BRAPIClient(authenticator: authenticator)
    }
    
    override class func tearDown() {
        super.tearDown()
        brClient = nil
        clearKeychain()
        keyStore.destroy()
    }
    
    func testSupportedCrypto() {
        let exp = expectation(description: "Fetch supported currencies")
        brClient.getCurrencyMetaData(type: .currencies) { metadata in
            
            XCTAssert(metadata.count > 0)
            let ids = metadata.values
                            .compactMap { $0.coinGeckoId ?? CoinGeckoCodes.map[$0.code.uppercased()] }
                            .filter { $0 != "stormx" } //not expecting to find stormx
            
            let chunkSize = 50
            let chunks = ids.chunked(by: chunkSize)
            var combinedResults: [String: FiatPriceInfo] = [:]
            let group = DispatchGroup()
            for chunk in chunks {
                group.enter()
                let vs = "usd"
                let resource = Resources.simplePrice(ids: chunk, vsCurrency: vs, options: [.change]) { (result: Result<[SimplePrice], CoinGeckoError>) in
                    guard case .success(let data) = result else { return group.leave() }
                    var missing = [String]()
                    chunk.forEach { id in
                        guard let simplePrice = data.first(where: { $0.id == id }) else {
                            missing.append(id)
                            return
                        }
                        let change = simplePrice.change24hr ?? 0.0
                        combinedResults[id] = FiatPriceInfo(changePercentage24Hrs: change,
                                                            change24Hrs: change*simplePrice.price/100,
                                                            price: simplePrice.price)
                    }
                    XCTAssert(missing.count == 0, "Missing exchange rate for: \(missing)")
                    group.leave()
                }
                self.coinGeckoClient.load(resource)
            }
            
            group.notify(queue: .main) {
                exp.fulfill()
            }
            
            
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
}
