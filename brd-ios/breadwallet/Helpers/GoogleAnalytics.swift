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

// swiftlint:disable type_body_length
struct GoogleAnalytics {
    struct Home: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Home"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Send: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Send"
        var data: [String: String]
        
        init(currencyId: String, cryptoRequestUrl: String) {
            data = ["currencyId": currencyId,
                    "cryptoRequestUrl": currencyId] // TODO: What is this?
        }
    }
    
    struct Receive: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Receive"
        var data: [String: String]
        
        init(currencyCode: String) {
            data = ["currencyCode": currencyCode]
        }
    }
    
    struct Registration: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Registration"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Transaction: GoogleAnalyticsLogData {
        var name = "GT_RW_Transaction"
        var data: [String: String]
        
        init(currencyId: String, txHash: String) {
            data = ["currencyId": currencyId,
                    "txHash": txHash]
        }
    }
    
    struct TransactionData: GoogleAnalyticsLogData {
        var name = "GT_RW_Transaction"
        var data: [String: String]
        
        init(transactionData: String) {
            data = ["transactionData": transactionData]
        }
    }
    
    struct Back: GoogleAnalyticsLogData {
        var name = "GT_RW_Back"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct BackTo: GoogleAnalyticsLogData {
        var name = "GT_RW_Back_To"
        var data: [String: String]
        
        init(transactionData: String) {
            data = ["transactionData": transactionData]
        }
    }
    
    struct BackGoToKyc: GoogleAnalyticsLogData {
        var name = "GT_RW_Back_GoToKyc"
        var data: [String: String]
        
        init(transactionData: String) {
            data = ["transactionData": transactionData]
        }
    }
    
    struct TwoFactorAuth: GoogleAnalyticsLogData {
        var name = "GT-RW-Two-Factor-Auth"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct VerifyEmail: GoogleAnalyticsLogData {
        var name = "GT_RW_Verify_Email"
        var data: [String: String]
        
        init(transactionData: String) {
            data = ["transactionData": transactionData]
        }
    }
    
    struct OpenVeriffBioAuthSdk: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Open_Veriff_Bio_Auth_Sdk"
        var data: [String: String]
        
        init(sessionUrl: String) {
            data = ["sessionUrl": sessionUrl]
        }
    }
    
    struct Feedback: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Feedback"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Scanner: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Scanner"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct LogcatViewer: GoogleAnalyticsLogData {
        var name = "GT_RW_Logcat_Viewer"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct MetadataViewer: GoogleAnalyticsLogData {
        var name = "GT_RW_Metadata_Viewer"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct NoInternetScreen: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_No_Internet_Screen"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct VerifyProfile: GoogleAnalyticsLogData {
        var name = "GT_RW_Open_Verify_Profile"
        var data: [String: String]
        
        init(type: String) {
            data = ["type": type]
        }
    }
    
    struct DeepLink: GoogleAnalyticsLogData {
        var name = "GT_RW_Open_Deep_Link"
        var data: [String: String]
        
        init(url: String, authenticated: String, link: String) {
            data = ["url": url, "authenticated": authenticated, "link": link]
        }
    }
    
    struct GoToInAppMessage: GoogleAnalyticsLogData {
        var name = "GT_RW_Go_To_In_App_Message"
        var data: [String: String]
        
        init(inAppMessage: String) {
            data = ["inAppMessage": inAppMessage]
        }
    }
    
    struct Wallet: GoogleAnalyticsLogData {
        var name = "GT_RW_Wallet"
        var data: [String: String]
        
        init(currencyCode: String) {
            data = ["currencyCode": currencyCode]
        }
    }
    
    struct SupportPage: GoogleAnalyticsLogData {
        var name = "GT_RW_Support_Page"
        var data: [String: String]
        
        init(articleId: String, currencyCode: String) {
            data = ["articleId": articleId, "currencyCode": currencyCode]
        }
    }
    
    struct GenericDialog: GoogleAnalyticsLogData {
        var name = "GT_RW_Generic_Dialog"
        var data: [String: String]
        
        init(args: String) {
            data = ["args": args]
        }
    }
    
    struct OpenPlaid: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Open_Plaid"
        var data: [String: String]
        
        init(configuration: String) {
            data = ["configuration": configuration]
        }
    }
    
    struct SupportDialog: GoogleAnalyticsLogData {
        var name = "GT_RW_Support_Dialog"
        var data: [String: String]
        
        init(topic: String) {
            data = ["topic": topic]
        }
    }
    
    struct ContactSupport: GoogleAnalyticsLogData {
        var name = "GT_RW_Conact_Support"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct KycComingSoon: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Kyc_Coming_Soon"
        var data: [String: String]
        
        init(type: String) {
            data = ["type": type]
        }
    }
    
    struct BioAuthCompleted: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Bio_Auth_Completed"
        var data: [String: String]
        
        init(type: String) {
            data = ["type": type] // TODO: What is this?
        }
    }
    
    struct SetPin: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Set_Pin"
        var data: [String: String]
        
        init(onboarding: String, skipWriteDownKey: String) {
            data = ["onboarding": onboarding,
                    "skipWriteDownKey": skipWriteDownKey] // TODO: What is this?
        }
    }
    
    struct GoToRecoveryKey: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Recovery_Key"
        var data: [String: String]
        
        init(mode: String) {
            data = ["mode": mode] // TODO: What is this?
        }
    }
    
    struct BrdLogin: GoogleAnalyticsLogData {
        var name = "GT_RW_Brd_Login"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Authentication: GoogleAnalyticsLogData {
        var name = "GT_RW_Bio_Authentication"
        var data: [String: String]
        
        init(mode: String) {
            data = ["mode": mode]
        }
    }
    
    struct PinReset: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Pin_Reset"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }

    struct PinResetCompleted: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Pin_Reset_Completed"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct CreateAccount: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Create_Account" // Same as PinResetCompleted?
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Buy: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Buy"
        var data: [String: String]
        
        init(type: String) {
            data = ["type": type]
        }
    }
    
    struct Sell: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Create_Sell"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Profile: GoogleAnalyticsLogData {
        var name = "GT_RW_Create_Profile"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }

    struct AddWallet: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Add_Wallet"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }

    struct NativeApiExplorer: GoogleAnalyticsLogData {
        var name = "GT_RW_Add_Wallet"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct WriteDownKey: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_On_Write_Down_Key"
        var data: [String: String]
        
        init(onComplete: String, requestAuth: String) {
            data = ["onComplete": onComplete, // TODO: What is this?
                    "requestAuth": requestAuth] // TODO: What is this?
        }
    }
    
    struct PaperKey: GoogleAnalyticsLogData {
        var name = "GT_RW_Paper_Key"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct PaperKeyProve: GoogleAnalyticsLogData {
        var name = "GT_RW_Paper_Key_Prove"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct PaperKeyProveCompleted: GoogleAnalyticsLogData {
        var name = "GT_RW_Paper_Key_Prove_Completed"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct Menu: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Menu"
        var data: [String: String]
        
        init(settingsOption: String) {
            data = ["settingsOption": settingsOption]
        }
    }
    
    struct TransactionComplete: GoogleAnalyticsLogData {
        var name = "GT_RW_Transaction_Complete"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct About: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct DisplayCurrency: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct NotificationsSettings: GoogleAnalyticsLogData {
        var name = "GT_RW_About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct ShareDataSettings: GoogleAnalyticsLogData {
        var name = "GT_RW_About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct FingerprintSettings: GoogleAnalyticsLogData {
        var name = "GT_RW_About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct WipeWallet: GoogleAnalyticsLogData {
        var name = "GT_RW_About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct OnBoarding: GoogleAnalyticsLogData {
        var name = "GT_RW_About"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct ImportWallet: GoogleAnalyticsLogData { // Added.
        var name = "GT_RW_Import_Wallet"
        var data: [String: String]
        
        init(scanned: String) {
            data = ["scanned": scanned] // TODO: What is this?
        }
    }
    
    struct BitcoinNodeSelector: GoogleAnalyticsLogData {
        var name = "GT_RW_Bitcoin_Node_Selector"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct LegacyAddress: GoogleAnalyticsLogData {
        var name = "GT_RW_Legacy_Address"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }
    
    struct SyncBlockchain: GoogleAnalyticsLogData {
        var name = "GT_RW_Sync_Blockchain"
        var data: [String: String]
        
        init(currencyCode: String) {
            data = ["currencyCode": currencyCode]
        }
    }
    
    struct FastSync: GoogleAnalyticsLogData {
        var name = "GT_RW_FastSync"
        var data: [String: String]
        
        init(currencyCode: String) {
            data = ["currencyCode": currencyCode]
        }
    }
    
    struct ATMMap: GoogleAnalyticsLogData {
        var name = "GT_RW_ATM_Map"
        var data: [String: String]
        
        init(url: String, mapJson: String) {
            data = ["url": url, "mapJson": mapJson]
        }
    }
    
    struct Signal: GoogleAnalyticsLogData {
        var name = "GT_RW_Signal"
        var data: [String: String]
        
        init() {
            data = [:]
        }
    }

    struct Staking: GoogleAnalyticsLogData {
        var name = "GT_RW_Staking"
        var data: [String: String]
        
        init(currencyId: String) {
            data = ["currencyId": currencyId]
        }
    }
    
    struct CreateGift: GoogleAnalyticsLogData {
        var name = "GT_RW_Create_Gift"
        var data: [String: String]
        
        init(currencyId: String) {
            data = ["currencyId": currencyId]
        }
    }
    
    struct ShareGift: GoogleAnalyticsLogData {
        var name = "GT_RW_Share_Gift"
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
        var name = "GT_RW_Select_Baker_Screen"
        var data: [String: String]
        
        init(bakers: String) {
            data = ["bakers": bakers]
        }
    }
    
    static func logEvent(_ log: GoogleAnalyticsLogData) {
        let data = log.data.merging(GoogleAnalytics.getUserinfo(), uniquingKeysWith: { (first, _) in first })
        
        Analytics.logEvent(log.name, parameters: data)
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
        
        return info
    }
}
// swiftlint:enable type_body_length
