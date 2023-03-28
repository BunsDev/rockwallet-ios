// 
//  GoogleAnalytics.swift
//  breadwallet
//
//  Created by Kanan Mamedoff on 28/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import Firebase
import FirebaseAnalytics

protocol GoogleAnalyticsLogData {
    var name: String { get set }
    var data: [String: String] { get set }
}

struct GoogleAnalytics {
    struct Home: GoogleAnalyticsLogData {
        var name = "GT-RW-Home"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Send: GoogleAnalyticsLogData {
        var name = "GT-RW-Send"
        var data: [String: String]
        
        init(currencyId: String, cryptoRequestUrl: String) {
            data = ["currencyId": currencyId,
                    "cryptoRequestUrl": currencyId]
        }
    }
    
    struct Receive: GoogleAnalyticsLogData {
        var name = "GT-RW-Receive"
        var data: [String: String]
        
        init(currencyCode: String) {
            data = ["currencyCode": currencyCode]
        }
    }
    
    struct Registration: GoogleAnalyticsLogData {
        var name = "GT-RW-Registration"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Transaction: GoogleAnalyticsLogData {
        var name = "GT-RW-Transaction"
        var data: [String: String]
        
        init(currencyId: String, txHash: String) {
            data = ["currencyId": currencyId,
                    "txHash": txHash]
        }
    }
    
    struct TransactionData: GoogleAnalyticsLogData {
        var name = "GT-RW-Transaction"
        var data: [String: String]
        
        init(transactionData: String) {
            data = ["transactionData": transactionData]
        }
    }
    
    struct Back: GoogleAnalyticsLogData {
        var name = "GT-RW-Back"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct BackTo: GoogleAnalyticsLogData {
        var name = "GT-RW-Back-To"
        var data: [String: String]
        
        init(transactionData: String) {
            data = ["transactionData": transactionData]
        }
    }
    
    struct BackGoToKyc: GoogleAnalyticsLogData {
        var name = "GT-RW-Back-GoToKyc"
        var data: [String: String]
        
        init(transactionData: String) {
            data = ["transactionData": transactionData]
        }
    }
    
    struct TwoFactorAuth: GoogleAnalyticsLogData {
        var name = "GT-RW-Transaction"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct VerifyEmail: GoogleAnalyticsLogData {
        var name = "GT-RW-Verify-Email"
        var data: [String: String]
        
        init(transactionData: String) {
            data = ["transactionData": transactionData]
        }
    }
    
    struct OpenVeriffBioAuthSdk: GoogleAnalyticsLogData {
        var name = "GT-RW-Open-Veriff-Bio-Auth-Sdk"
        var data: [String: String]
        
        init(sessionUrl: String) {
            data = ["sessionUrl": sessionUrl]
        }
    }
    
    struct Feedback: GoogleAnalyticsLogData {
        var name = "GT-RW-Feedback"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Scanner: GoogleAnalyticsLogData {
        var name = "GT-RW-Scanner"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct LogcatViewer: GoogleAnalyticsLogData {
        var name = "GT-RW-Logcat-Viewer"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct MetadataViewer: GoogleAnalyticsLogData {
        var name = "GT-RW-Metadata-Viewer"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct NoInternetScreen: GoogleAnalyticsLogData {
        var name = "GT-RW-No-Internet-Screen"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct VerifyProfile: GoogleAnalyticsLogData {
        var name = "GT-RW-Open-Verify-Profile"
        var data: [String: String]
        
        init(type: String) {
            data = ["type": type]
        }
    }
    
    struct DeepLink: GoogleAnalyticsLogData {
        var name = "GT-RW-Open-Deep-Link"
        var data: [String: String]
        
        init(url: String, authenticated: String, link: String) {
            data = ["url": url, "authenticated": authenticated, "link": link]
        }
    }
    
    struct GoToInAppMessage: GoogleAnalyticsLogData {
        var name = "GT-RW-Go-To-In-App-Message"
        var data: [String: String]
        
        init(inAppMessage: String) {
            data = ["inAppMessage": inAppMessage]
        }
    }
    
    struct Wallet: GoogleAnalyticsLogData {
        var name = "GT-RW-Wallet"
        var data: [String: String]
        
        init(currencyCode: String) {
            data = ["currencyCode": currencyCode]
        }
    }
    
    struct SupportPage: GoogleAnalyticsLogData {
        var name = "GT-RW-Support-Page"
        var data: [String: String]
        
        init(articleId: String, currencyCode: String) {
            data = ["articleId": articleId, "currencyCode": currencyCode]
        }
    }
    
    struct GenericDialog: GoogleAnalyticsLogData {
        var name = "GT-RW-Generic-Dialog"
        var data: [String: String]
        
        init(args: String) {
            data = ["args": args]
        }
    }
    
    struct OpenPlaid: GoogleAnalyticsLogData {
        var name = "GT-RW-Open-Plaid"
        var data: [String: String]
        
        init(configuration: String) {
            data = ["configuration": configuration]
        }
    }
    
    struct SupportDialog: GoogleAnalyticsLogData {
        var name = "GT-RW-Support-Dialog"
        var data: [String: String]
        
        init(topic: String) {
            data = ["topic": topic]
        }
    }
    
    struct ContactSupport: GoogleAnalyticsLogData {
        var name = "GT-RW-Conact-Support"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct KycComingSoon: GoogleAnalyticsLogData {
        var name = "GT-RW-Kyc-Coming-Soon"
        var data: [String: String]
        
        init(type: String) {
            data = ["type": type]
        }
    }
    
    struct BioAuthCompleted: GoogleAnalyticsLogData {
        var name = "GT-RW-Bio-Auth-Completed"
        var data: [String: String]
        
        init(type: String) {
            data = ["type": type]
        }
    }
    
    struct SetPin: GoogleAnalyticsLogData {
        var name = "GT-RW-Set-Pin"
        var data: [String: String]
        
        init(onboarding: String, skipWriteDownKey: String) {
            data = ["onboarding": onboarding, "skipWriteDownKey": skipWriteDownKey]
        }
    }
    
    struct GoToRecoveryKey: GoogleAnalyticsLogData {
        var name = "GT-RW-Recovery-Key"
        var data: [String: String]
        
        init(mode: String) {
            data = ["mode": mode]
        }
    }
    
    struct BrdLogin: GoogleAnalyticsLogData {
        var name = "GT-RW-Brd-Login"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Authentication: GoogleAnalyticsLogData {
        var name = "GT-RW-Bio-Authentication"
        var data: [String: String]
        
        init(mode: String) {
            data = ["mode": mode]
        }
    }
    
    struct PinReset: GoogleAnalyticsLogData {
        var name = "GT-RW-Pin-Reset"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }

    struct PinResetCompleted: GoogleAnalyticsLogData {
        var name = "GT-RW-Pin-Reset-Completed"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct CreateAccount: GoogleAnalyticsLogData {
        var name = "GT-RW-Create-Account"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Buy: GoogleAnalyticsLogData {
        var name = "GT-RW-Buy"
        var data: [String: String]
        
        init(type: String) {
            data = ["type": type]
        }
    }
    
    struct Sell: GoogleAnalyticsLogData {
        var name = "GT-RW-Create-Sell"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Profile: GoogleAnalyticsLogData {
        var name = "GT-RW-Create-Profile"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }

    struct AddWallet: GoogleAnalyticsLogData {
        var name = "GT-RW-Add-Wallet"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }

    struct NativeApiExplorer: GoogleAnalyticsLogData {
        var name = "GT-RW-Add-Wallet"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct WriteDownKey: GoogleAnalyticsLogData {
        var name = "GT-RW-On-Write-Down-Key"
        var data: [String: String]
        
        init(onComplete: String, requestAuth: String) {
            data = ["onComplete": onComplete, "requestAuth": requestAuth]
        }
    }
    
    struct PaperKey: GoogleAnalyticsLogData {
        var name = "GT-RW-Paper-Key"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct PaperKeyProve: GoogleAnalyticsLogData {
        var name = "GT-RW-Paper-Key-Prove"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct PaperKeyProveCompleted: GoogleAnalyticsLogData {
        var name = "GT-RW-Paper-Key-Prove-Completed"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Menu: GoogleAnalyticsLogData {
        var name = "GT-RW-Menu"
        var data: [String: String]
        
        init(settingsOption: String) {
            data = ["settingsOption": settingsOption]
        }
    }
    
    struct TransactionComplete: GoogleAnalyticsLogData {
        var name = "GT-RW-Transaction-Complete"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct About: GoogleAnalyticsLogData {
        var name = "GT-RW-About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct DisplayCurrency: GoogleAnalyticsLogData {
        var name = "GT-RW-About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct NotificationsSettings: GoogleAnalyticsLogData {
        var name = "GT-RW-About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct ShareDataSettings: GoogleAnalyticsLogData {
        var name = "GT-RW-About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct FingerprintSettings: GoogleAnalyticsLogData {
        var name = "GT-RW-About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct WipeWallet: GoogleAnalyticsLogData {
        var name = "GT-RW-About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct OnBoarding: GoogleAnalyticsLogData {
        var name = "GT-RW-About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct ImportWallet: GoogleAnalyticsLogData {
        var name = "GT-RW-Import-Wallet"
        var data: [String: String]
        
        init(scanned: String) {
            data = ["scanned": scanned]
        }
    }
    
    struct BitcoinNodeSelector: GoogleAnalyticsLogData {
        var name = "GT-RW-Bitcoin-Node-Selector"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct LegacyAddress: GoogleAnalyticsLogData {
        var name = "GT-RW-Legacy-Address"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct SyncBlockchain: GoogleAnalyticsLogData {
        var name = "GT-RW-Sync-Blockchain"
        var data: [String: String]
        
        init(currencyCode: String) {
            data = ["currencyCode": currencyCode]
        }
    }
    
    struct FastSync: GoogleAnalyticsLogData {
        var name = "GT-RW-FastSync"
        var data: [String: String]
        
        init(currencyCode: String) {
            data = ["currencyCode": currencyCode]
        }
    }
    
    struct ATMMap: GoogleAnalyticsLogData {
        var name = "GT-RW-ATM-Map"
        var data: [String: String]
        
        init(url: String, mapJson: String) {
            data = ["url": url, "mapJson": mapJson]
        }
    }
    
    struct Signal: GoogleAnalyticsLogData {
        var name = "GT-RW-Signal"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }

    struct Staking: GoogleAnalyticsLogData {
        var name = "GT-RW-Staking"
        var data: [String: String]
        
        init(currencyId: String) {
            data = ["currencyId": currencyId]
        }
    }
    
    struct CreateGift: GoogleAnalyticsLogData {
        var name = "GT-RW-Create-Gift"
        var data: [String: String]
        
        init(currencyId: String) {
            data = ["currencyId": currencyId]
        }
    }
    
    struct ShareGift: GoogleAnalyticsLogData {
        var name = "GT-RW-Share-Gift"
        var data: [String: String]
        
        init(giftUrl: String, txHash: String, recipientName: String, giftAmount: String, giftAmountFiat: String, pricePerUnit: String, replaceTop: String) {
            data = ["giftUrl": giftUrl,
                    "txHash": txHash,
                    "recipientName": recipientName,
                    "giftAmount": giftAmount,
                    "giftAmountFiat": giftAmountFiat,
                    "pricePerUnit": pricePerUnit,
                    "replaceTop": replaceTop]
        }
    }
    
    struct SelectBakerScreen: GoogleAnalyticsLogData {
        var name = "GT-RW-Select-Baker-Screen"
        var data: [String: String]
        
        init(bakers: String) {
            data = ["bakers": bakers]
        }
    }
    
    static func logEvent(_ log: GoogleAnalyticsLogData) {
        Analytics.logEvent(log.name, parameters: log.data)
    }
    
    static func getUserinfo() -> [String: String] {
        guard let profile = UserManager.shared.profile else { return [:] }
        
        var info = [String: String]()
        info["email"] = profile.email
        info["country"] = profile.country?.iso2
        info["kyc_status"] = profile.status.value
        info["kyc_failure_reason"] = profile.kycFailureReason
        info["exchange_limits"] = String(describing: profile.limits)
        info["is_registered"] = profile.isMigrated.description
        info["kyc_access_rights"] = String(describing: profile.kycAccessRights)
        info["has_pending_limits"] = profile.hasPendingLimits.description
        
        return [:]
    }
}
