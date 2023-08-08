//
//  SimpleRedux.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-21.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import WalletKit

// swiftlint:disable legacy_hashing

typealias Reducer = (State) -> State
typealias ReduxSelector = (_ oldState: State, _ newState: State) -> Bool

protocol Action {
    var reduce: Reducer { get }
}

//We need reference semantics for Subscribers, so they are restricted to classes
protocol Subscriber: AnyObject {}

extension Subscriber {
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

typealias StateUpdatedCallback = (State) -> Void

struct Subscription {
    let selector: ((_ oldState: State, _ newState: State) -> Bool)
    let callback: (State) -> Void
}

struct Trigger {
    let name: TriggerName
    let callback: (TriggerName?) -> Void
}

extension TriggerName: Equatable {}

// Remember to add to triggers to == fuction below
enum TriggerName {
    case presentFaq(String, Currency?)
    case registerForPushNotificationToken
    case lock
    case promptBiometrics
    case promptPaperKey
    case promptUpgradePin
    case blockModalDismissal
    case unblockModalDismissal
    case openFile(Data)
    case paymentRequest(PaymentRequest?)
    case scanQr
    case authenticateForPlatform(String, Bool, (PlatformAuthResult) -> Void) // (prompt, allowBiometricAuth, callback)
    case confirmTransaction(Currency?, Amount?, Amount?, FeeLevel, String, (Bool) -> Void) // currency, amount, fee, displayFeeLevel, address, callback
    case hideStatusBar
    case showStatusBar
    case lightWeightAlert(String)
    case showAlert(UIAlertController?)
    case didWipeWallet
    case didUpgradePin
    case txMetaDataUpdated(String)
    case promptShareData
    case didApplyKyc
    case didCreateAccount
    case didSetTwoStep
    case didWritePaperKey
    case wipeWalletNoPrompt
    case showCurrency(Currency?)
    case fetchInbox
    case optInSegWit
    case didViewTransactions([Transaction]?)
    case showInAppNotification(BRDMessage?)
    case didSyncKVStore
    case createAccount(Currency?, ((Wallet?) -> Void)?)
    case handleGift(URL)
    case reImportGift((any TxViewModel)?)
    case didSelectBaker(Baker?)
    case promptKyc
    case promptNoAccount
    case promptLimitsAuthentication
    case handleDeeplink
    case promptTwoStep
    case reloadBuy
    case refreshToken
    case showSell
}

func == (lhs: TriggerName, rhs: TriggerName) -> Bool {
    switch (lhs, rhs) {
    case (.presentFaq, .presentFaq):
        return true
    case (.registerForPushNotificationToken, .registerForPushNotificationToken):
        return true
    case (.lock, .lock):
        return true
    case (.promptBiometrics, .promptBiometrics):
        return true
    case (.promptPaperKey, .promptPaperKey):
        return true
    case (.promptUpgradePin, .promptUpgradePin):
        return true
    case (.blockModalDismissal, .blockModalDismissal):
        return true
    case (.unblockModalDismissal, .unblockModalDismissal):
        return true
    case (.openFile, .openFile):
        return true
    case (.paymentRequest, .paymentRequest):
        return true
    case (.scanQr, .scanQr):
        return true
    case (.authenticateForPlatform, .authenticateForPlatform):
        return true
    case (.confirmTransaction, .confirmTransaction):
        return true
    case (.showStatusBar, .showStatusBar):
        return true
    case (.hideStatusBar, .hideStatusBar):
        return true
    case (.lightWeightAlert, .lightWeightAlert):
        return true
    case (.showAlert, .showAlert):
        return true
    case (.didWipeWallet, .didWipeWallet):
        return true
    case (.didUpgradePin, .didUpgradePin):
        return true
    case (.didApplyKyc, .didApplyKyc):
        return true
    case (.didCreateAccount, .didCreateAccount):
        return true
    case (.didSetTwoStep, .didSetTwoStep):
        return true
    case (.txMetaDataUpdated, .txMetaDataUpdated):
        return true
    case (.promptShareData, .promptShareData):
        return true
    case (.didWritePaperKey, .didWritePaperKey):
        return true
    case (.wipeWalletNoPrompt, .wipeWalletNoPrompt):
        return true
    case (.showCurrency, .showCurrency):
        return true
    case (.fetchInbox, .fetchInbox):
        return true
    case (.optInSegWit, .optInSegWit):
        return true
    case (.didViewTransactions, .didViewTransactions):
        return true
    case (.showInAppNotification, .showInAppNotification):
        return true
    case (.didSyncKVStore, .didSyncKVStore):
        return true
    case (.createAccount, .createAccount):
        return true
    case (.promptTwoStep, .promptTwoStep):
        return true
    case (.handleGift, .handleGift):
        return true
    case (.reImportGift, .reImportGift):
        return true
    case (.didSelectBaker, .didSelectBaker):
        return true
    case (.promptKyc, .promptKyc):
        return true
    case (.promptNoAccount, .promptNoAccount):
        return true
    case (.promptLimitsAuthentication, .promptLimitsAuthentication):
        return true
    case (.handleDeeplink, .handleDeeplink):
        return true
    case (.reloadBuy, .reloadBuy):
        return true
    case (.refreshToken, .refreshToken):
        return true
    case (.showSell, .showSell):
        return true
    default:
        return false
    }
}

class Store {
    private static let shared = Store()
    private init() { }
    
    private var isClearingSubscriptions = false

    // MARK: - Public
    static func perform(action: Action) {
        Store.shared.perform(action: action)
    }

    static func trigger(name: TriggerName) {
        Store.shared.trigger(name: name)
    }

    static var state: State {
        return shared.state
    }
    
    static func subscribe(_ subscriber: Subscriber, selector: @escaping ReduxSelector, callback: @escaping (State) -> Void) {
        Store.shared.subscribe(subscriber, selector: selector, callback: callback)
    }

    static func subscribe(_ subscriber: Subscriber, name: TriggerName, callback: @escaping (TriggerName?) -> Void) {
        Store.shared.subscribe(subscriber, name: name, callback: callback)
    }

    static func lazySubscribe(_ subscriber: Subscriber, selector: @escaping ReduxSelector, callback: @escaping (State) -> Void) {
        Store.shared.lazySubscribe(subscriber, selector: selector, callback: callback)
    }

    static func unsubscribe(_ subscriber: Subscriber) {
        Store.shared.unsubscribe(subscriber)
    }

    static func removeAllSubscriptions() {
        Store.shared.removeAllSubscriptions()
    }

    // MARK: - Private
    func perform(action: Action) {
        assert(Thread.isMainThread)
        state = action.reduce(state)
    }

    func trigger(name: TriggerName) {
        triggers
            .flatMap { $0.value }
            .filter { $0.name == name }
            .forEach { trigger in
                DispatchQueue.main.async {
                    trigger.callback(name)
                }
        }
    }

    //Subscription callback is immediately called with current State value on subscription
    //and then any time the selected value changes
    func subscribe(_ subscriber: Subscriber, selector: @escaping ReduxSelector, callback: @escaping (State) -> Void) {
        lazySubscribe(subscriber, selector: selector, callback: callback)
        callback(state)
    }

    //Same as subscribe(), but doesn't call the callback with current state upon subscription
    func lazySubscribe(_ subscriber: Subscriber, selector: @escaping ReduxSelector, callback: @escaping (State) -> Void) {
        let key = subscriber.hashValue
        let subscription = Subscription(selector: selector, callback: callback)
        subscriptions[key, default: []].append(subscription)
    }

    func subscribe(_ subscriber: Subscriber, name: TriggerName, callback: @escaping (TriggerName?) -> Void) {
        let key = subscriber.hashValue
        let trigger = Trigger(name: name, callback: callback)
        triggers[key, default: []].append(trigger)
    }

    func unsubscribe(_ subscriber: Subscriber) {
        guard !isClearingSubscriptions else { return }
        self.subscriptions.removeValue(forKey: subscriber.hashValue)
        self.triggers.removeValue(forKey: subscriber.hashValue)
    }

    // MARK: - Private
    private(set) var state = State.initial {
        didSet {
            subscriptions
                .flatMap { $0.value } //Retreive all subscriptions (subscriptions is a dictionary)
                .filter { $0.selector(oldValue, state) }
                .forEach { subscription in
                    DispatchQueue.main.async {
                        subscription.callback(self.state)
                    }
            }
        }
    }

    func removeAllSubscriptions() {
        DispatchQueue.main.async {
            // removing the subscription may trigger deinit of the object and a duplicate call to unsubscribe
            self.isClearingSubscriptions = true
            self.subscriptions.removeAll()
            self.triggers.removeAll()
        }
    }

    private var subscriptions: [Int: [Subscription]] = [:]
    private var triggers: [Int: [Trigger]] = [:]
}

// swiftlint:enable legacy_hashing
