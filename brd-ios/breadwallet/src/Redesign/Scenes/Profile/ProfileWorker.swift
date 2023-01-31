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

enum CustomerRole: String, Codable {
    case customer
    case unverified
    case kyc1
    case kyc2
}

struct Limits: Codable {
    var exchangeType: ExchangeType?
    var interval: Interval?
    var limit: Decimal?
    var isCustom: Bool?
}

enum ExchangeFlow {
    case buy
    case swap
}

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

struct ProfileResponseData: ModelResponse {
    var country: String?
    var state: String?
    var dateOfBirth: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var kycStatus: String?
    var kycFailureReason: String?
    var roles: [CustomerRole]
    var limits: [Limits]?
    
    var exchangeLimits: ExchangeLimits?
    var kycAccessRights: AccessRights?
    
    struct ExchangeLimits: Codable {
        var swapAllowanceLifetime: Decimal
        var swapAllowanceDaily: Decimal
        var swapAllowancePerExchange: Decimal
        var usedSwapLifetime: Decimal
        var usedSwapDaily: Decimal
        
        var buyAllowanceLifetime: Decimal
        var buyAllowanceDaily: Decimal
        var buyAllowancePerPurchase: Decimal
        var usedBuyLifetime: Decimal
        var usedBuyDaily: Decimal
        
        var buyAchAllowanceLifetime: Decimal
        var buyAchAllowanceDaily: Decimal
        var buyAchAllowancePerPurchase: Decimal
        var usedBuyAchLifetime: Decimal
        var usedBuyAchDaily: Decimal
    }
    
    struct AccessRights: Codable {
        var hasSwapAccess: Bool
        var hasBuyAccess: Bool
        var hasAchAccess: Bool
        var restrictionReason: String?
    }
}

struct Profile: Model {
    var country: String?
    var state: String?
    var dateOfBirth: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var status: VerificationStatus
    var failureReason: String?
    
    var swapAllowanceLifetime: Decimal
    var swapAllowanceDaily: Decimal
    var swapAllowancePerExchange: Decimal
    var usedSwapLifetime: Decimal
    var usedSwapDaily: Decimal
    
    var buyAllowanceLifetime: Decimal
    var buyAllowanceDaily: Decimal
    var buyAllowancePerPurchase: Decimal
    var usedBuyLifetime: Decimal
    var usedBuyDaily: Decimal
    
    var achAllowanceLifetime: Decimal
    var achAllowanceDaily: Decimal
    var achAllowancePerPurchase: Decimal
    var usedAchLifetime: Decimal
    var usedAchDaily: Decimal
    
    var roles: [CustomerRole]
    
    var canBuy: Bool
    var canSwap: Bool
    var canUseAch: Bool
    var restrictionReason: String?
    var limits: [Limits]?
    
    var swapDailyRemainingLimit: Decimal {
        return swapAllowanceDaily - usedSwapDaily
    }
    
    var swapLifetimeRemainingLimit: Decimal {
        return swapAllowanceLifetime - usedSwapLifetime
    }
    
    var buyDailyRemainingLimit: Decimal {
        return buyAllowanceDaily - usedBuyDaily
    }
    
    var buyLifetimeRemainingLimit: Decimal {
        return buyAllowanceLifetime - usedBuyLifetime
    }
    
    var achDailyRemainingLimit: Decimal {
        return achAllowanceDaily - usedAchDaily
    }
    
    var achLifetimeRemainingLimit: Decimal {
        return achAllowanceLifetime - usedAchLifetime
    }
}

class ProfileMapper: ModelMapper<ProfileResponseData, Profile> {
    override func getModel(from response: ProfileResponseData?) -> Profile? {
        guard let response = response else { return nil }
        let limits = response.exchangeLimits
        
        let swapAllowanceLifetime = limits?.swapAllowanceLifetime ?? 0
        let swapAllowanceDaily = limits?.swapAllowanceDaily ?? 0
        let swapAllowancePerExchange = limits?.swapAllowancePerExchange ?? 0
        let usedSwapDaily = limits?.usedSwapDaily ?? 0
        let usedBuyLifetime = limits?.usedBuyLifetime ?? 0
        
        let buyAllowanceLifetime = limits?.buyAllowanceLifetime ?? 0
        let buyAllowanceDaily = limits?.buyAllowanceDaily ?? 0
        let buyAllowancePerPurchase = limits?.buyAllowancePerPurchase ?? 0
        let usedSwapLifetime = limits?.usedSwapLifetime ?? 0
        let usedBuyDaily = limits?.usedBuyDaily ?? 0
        
        let achAllowanceLifetime = limits?.buyAchAllowanceLifetime ?? 0
        let achAllowanceDaily = limits?.buyAchAllowanceDaily ?? 0
        let achAllowancePerPurchase = limits?.buyAchAllowancePerPurchase ?? 0
        let usedAchLifetime = limits?.usedBuyAchLifetime ?? 0
        let usedAchDaily = limits?.usedBuyAchDaily ?? 0
        
        return .init(country: response.country,
                     state: response.state,
                     dateOfBirth: response.dateOfBirth,
                     firstName: response.firstName,
                     lastName: response.lastName,
                     email: response.email,
                     status: .init(rawValue: response.kycStatus),
                     failureReason: response.kycFailureReason,
                     swapAllowanceLifetime: swapAllowanceLifetime,
                     swapAllowanceDaily: swapAllowanceDaily,
                     swapAllowancePerExchange: swapAllowancePerExchange,
                     usedSwapLifetime: usedSwapLifetime,
                     usedSwapDaily: usedSwapDaily,
                     buyAllowanceLifetime: buyAllowanceLifetime,
                     buyAllowanceDaily: buyAllowanceDaily,
                     buyAllowancePerPurchase: buyAllowancePerPurchase,
                     usedBuyLifetime: usedBuyLifetime,
                     usedBuyDaily: usedBuyDaily,
                     achAllowanceLifetime: achAllowanceLifetime,
                     achAllowanceDaily: achAllowanceDaily,
                     achAllowancePerPurchase: achAllowancePerPurchase,
                     usedAchLifetime: usedAchLifetime,
                     usedAchDaily: usedAchDaily,
                     roles: response.roles,
                     canBuy: response.kycAccessRights?.hasBuyAccess ?? false,
                     canSwap: response.kycAccessRights?.hasSwapAccess ?? false,
                     canUseAch: response.kycAccessRights?.hasAchAccess ?? false,
                     restrictionReason: response.kycAccessRights?.restrictionReason,
                     limits: response.limits)
    }
}

class ProfileWorker: BaseApiWorker<ProfileMapper> {
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.profile)
    }
}
