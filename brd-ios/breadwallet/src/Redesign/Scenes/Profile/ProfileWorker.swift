// 
//  ProfileWorker.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct ProfileResponseData: ModelResponse {
    let email: String?
    let kycStatus: String?
    let exchangeLimits: [ExchangeLimit]?
    let kycAccessRights: AccessRights?
    let kycFailureReason: String?
    let isRegistered: Bool?
    
    struct AccessRights: Codable {
        let hasSwapAccess: Bool
        let hasBuyAccess: Bool
        let hasAchAccess: Bool
        let restrictionReason: String?
    }
    
    struct ExchangeLimit: Codable {
        let exchangeType: ExchangeType?
        let interval: Interval?
        let limit: Decimal?
        let isCustom: Bool?
        
        enum ExchangeType: String, Codable {
            case swap = "SWAP"
            case buyCard = "BUY_CARD"
            case buyAch = "BUY_ACH"
            case sell = "SELL_ACH"
        }
        
        enum Interval: String, Codable {
            case daily = "DAILY"
            case weekly = "WEEKLY"
            case monthly = "MONTHLY"
            case lifetime = "LIFETIME"
            case perExchange = "PER_EXCHANGE"
            case minimum = "MINIMUM"
        }
    }
}

struct Profile: Model {
    let email: String
    let status: VerificationStatus
    let limits: [ProfileResponseData.ExchangeLimit]
    let kycAccessRights: AccessRights
    let isMigrated: Bool
    
    struct AccessRights {
        let hasSwapAccess: Bool
        let hasBuyAccess: Bool
        let hasAchAccess: Bool
    }
    
    var swapAllowanceLifetime: Decimal {
        return limits.first(where: { $0.interval == .lifetime && $0.exchangeType == .swap })?.limit ?? 0
    }
    var swapAllowanceDaily: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .swap })?.limit ?? 0
    }
    
    var swapAllowancePerExchange: Decimal {
        return limits.first(where: { $0.interval == .perExchange && $0.exchangeType == .swap })?.limit ?? 0
    }
    
    var buyAllowanceLifetime: Decimal {
        return limits.first(where: { $0.interval == .lifetime && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowanceDaily: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowancePerPurchase: Decimal {
        return limits.first(where: { $0.interval == .perExchange && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    
    var achAllowanceLifetime: Decimal {
        return limits.first(where: { $0.interval == .lifetime && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    var achAllowanceDaily: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    var achAllowancePerPurchase: Decimal {
        return limits.first(where: { $0.interval == .perExchange && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    
    var buyAllowanceWeekly: Decimal {
        return limits.first(where: { $0.interval == .weekly && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowanceMonthly: Decimal {
        return limits.first(where: { $0.interval == .monthly && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowanceDailyMin: Decimal {
        return limits.first(where: { $0.interval == .minimum && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowanceDailyMax: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    
    var achAllowanceWeekly: Decimal {
        return limits.first(where: { $0.interval == .weekly && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    var achAllowanceMonthly: Decimal {
        return limits.first(where: { $0.interval == .monthly && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    var achAllowanceDailyMin: Decimal {
        return limits.first(where: { $0.interval == .minimum && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    var achAllowanceDailyMax: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .buyAch })?.limit ?? 0
    }
}

class ProfileMapper: ModelMapper<ProfileResponseData, Profile> {
    override func getModel(from response: ProfileResponseData?) -> Profile? {
        guard let response = response else { return nil }
        
        return Profile(email: response.email ?? "",
                       status: VerificationStatus(rawValue: response.kycStatus),
                       limits: response.exchangeLimits ?? [],
                       kycAccessRights: Profile.AccessRights(hasSwapAccess: response.kycAccessRights?.hasSwapAccess ?? false,
                                                             hasBuyAccess: response.kycAccessRights?.hasBuyAccess ?? false,
                                                             hasAchAccess: response.kycAccessRights?.hasAchAccess ?? false),
                       isMigrated: response.isRegistered ?? false)
    }
}

class ProfileWorker: BaseApiWorker<ProfileMapper> {
    override func getUrl() -> String {
        return APIURLHandler.getUrl(WalletEndpoints.profile)
    }
}
