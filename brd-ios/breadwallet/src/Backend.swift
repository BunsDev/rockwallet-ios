//
//  Backend.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2018-08-15.
//  Copyright © 2018-2019 Breadwinner AG. All rights reserved.
//

import Foundation
import WebKit
import Cosmos

class Backend {
    
    // MARK: - Singleton
    
    private static let shared = Backend()
    private init() {
        apiClient = BRAPIClient(authenticator: NoAuthWalletAuthenticator())
        bdbClient = BdbServiceCompanion().create()
    }
    
    // MARK: - Private
    
    private var apiClient: BRAPIClient
    private var bdbClient: BdbService
    private var kvStore: BRReplicatedKVStore?
    private var exchangeUpdater: ExchangeUpdater?
    
    // MARK: - Public
    
    static var isConnected: Bool {
        return (apiClient.authKey != nil)
    }
    
    static var apiClient: BRAPIClient {
        return shared.apiClient
    }
    
    static var bdbClient: BdbService {
        return shared.bdbClient
    }
    
    static var kvStore: BRReplicatedKVStore? {
        return shared.kvStore
    }

    static func updateExchangeRates() {
        shared.exchangeUpdater?.refresh()
    }
    
    // MARK: Setup
    
    static func connect(authenticator: WalletAuthenticator) {
        guard let key = authenticator.apiAuthKey else { return }
        shared.apiClient = BRAPIClient(authenticator: authenticator)
        shared.kvStore = try? BRReplicatedKVStore(encryptionKey: key, remoteAdaptor: KVStoreAdaptor(client: shared.apiClient))
        shared.exchangeUpdater = ExchangeUpdater()
        shared.bdbClient = BdbServiceCompanion().createForTest(bdbAuthToken: authenticator.bdbAuthToken?.token ?? "")
    }
    
    /// Disconnect backend services and reset API auth
    static func disconnectWallet() {
        URLCache.shared.removeAllCachedResponses()
        shared.exchangeUpdater = nil
        shared.kvStore = nil
        shared.apiClient = BRAPIClient(authenticator: NoAuthWalletAuthenticator())
        shared.bdbClient = BdbServiceCompanion().create()
    }
}
