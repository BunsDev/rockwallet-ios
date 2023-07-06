//
//  Transaction.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2018-01-13.
//  Copyright © 2018-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import WalletKit

/// Transacton status
enum TransactionStatus: String, Hashable, ModelResponse {
    /// Zero confirmations
    case pending = "PENDING"
    /// One or more confirmations
    case confirmed
    /// Sufficient confirmations to deem complete (coin-specific)
    case complete = "COMPLETE"
    /// Invalid / error
    case invalid
    /// Failed
    case failed = "FAILED"
    /// Refunded
    case refunded = "REFUNDED"
    /// Manually settled
    case manuallySettled = "MANUALLY_SETTLED"
    
    init?(string: String?) {
        guard let string = string?.uppercased() else {
            self = .failed
            return
        }
        self.init(rawValue: string)
    }
    
    var viewModel: AssetViewModel? {
        switch self {
        case .pending:
            return .init(icon: Asset.pendingIcon.image, title: L10n.Staking.statusPending)
            
        case .complete, .confirmed:
            return .init(icon: Asset.completeIcon.image, title: L10n.Transaction.complete)
            
        case .failed, .invalid:
            return .init(icon: Asset.errorIcon.image.withRenderingMode(.alwaysOriginal), title: L10n.Transaction.failed)
            
        case .refunded:
            return .init(icon: Asset.refundedIcon.image.withRenderingMode(.alwaysOriginal), title: L10n.Transaction.refunded)
            
        case .manuallySettled:
            return .init(icon: Asset.completeIcon.image.withRenderingMode(.alwaysOriginal), title: L10n.Transaction.manuallySettled)
            
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .pending: return LightColors.Pending.two
        case .failed, .invalid, .refunded: return LightColors.Error.two
        case .complete, .confirmed, .manuallySettled: return LightColors.Success.two
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .pending: return LightColors.Pending.one
        case .failed, .invalid, .refunded: return LightColors.Error.one
        case .complete, .confirmed, .manuallySettled: return LightColors.Success.one
        }
    }
}

/// Wrapper for BRCrypto TransferFeeBasis
struct FeeBasis {
    private let core: TransferFeeBasis
    
    let currency: Currency
    var amount: Amount {
        return Amount(cryptoAmount: core.fee, currency: currency)
    }
    var unit: CurrencyUnit {
        return core.unit
    }
    var pricePerCostFactor: Amount {
        return Amount(cryptoAmount: core.pricePerCostFactor, currency: currency)
    }
    var costFactor: Double {
        return core.costFactor
    }
    
    init(core: TransferFeeBasis, currency: Currency) {
        self.core = core
        self.currency = currency
    }
}

// MARK: -

/// Wrapper for BRCrypto Transfer
class Transaction {
    let transfer: WalletKit.Transfer
    let wallet: Wallet

    var currency: Currency { return wallet.currency }
    var confirmations: UInt64 {
        return transfer.confirmations ?? 0
    }
    var blockNumber: UInt64? {
        return transfer.confirmation?.blockNumber
    }
    //TODO:CRYPTO used as non-optional by tx metadata and rescan
    var blockHeight: UInt64 {
        return blockNumber ?? 0
    }

    var targetAddress: String { return transfer.target?.sanitizedDescription ?? "" }
    var sourceAddress: String { return transfer.source?.sanitizedDescription ?? "" }
    var toAddress: String { return targetAddress }
    var fromAddress: String { return sourceAddress }

    var amount: Amount {
        if currency.uid == transfer.amount.currency.uid {
            return Amount(cryptoAmount: transfer.amount, currency: currency)
        } else {
            return Amount.zero(currency)
        }
    }
    var fee: Amount { return Amount(cryptoAmount: transfer.fee, currency: wallet.feeCurrency) }

    var feeBasis: FeeBasis? {
        guard let core = (transfer.confirmedFeeBasis ?? transfer.estimatedFeeBasis) else { return nil }
        return FeeBasis(core: core,
                        currency: wallet.feeCurrency)
    }

    var created: Date? {
        if let confirmationTimestamp = confirmationTimestamp {
            return Date(timeIntervalSince1970: confirmationTimestamp)
        } else {
            return nil
        }
    }
    /// Confirmation time if confirmed, or current time for pending transactions (seconds since UNIX epoch)
    var timestamp: TimeInterval {
        return confirmationTimestamp ?? Date().timeIntervalSince1970
    }

    private var confirmationTimestamp: TimeInterval? {
        guard let seconds = transfer.confirmation?.timestamp else { return nil }
        let timestamp = TimeInterval(seconds)
        guard timestamp > NSTimeIntervalSince1970 else {
            // compensates for a legacy database migration bug (IOS-1453)
            return timestamp + NSTimeIntervalSince1970
        }
        return timestamp
    }
    
    var hash: String { return transfer.hash?.description ?? "" }
    
    var exchange: ExchangeDetail?
    
    var status: TransactionStatus {
        switch exchange?.type {
        case .swap:
            return exchange?.status ?? .failed
            
        default:
            switch transfer.state {
            case .created, .signed, .submitted, .pending:
                return .pending
                
            case .included:
                
                let buyTransaction = exchange?.type == .buyCard || exchange?.type == .buyAch || exchange?.type == .instantAch
                
                switch Int(confirmations) {
                case 0:
                    return buyTransaction ? (exchange?.status ?? .failed) : .pending
                    
                case 1..<currency.confirmationsUntilFinal:
                    return .confirmed
                    
                default:
                    return buyTransaction ? (exchange?.status ?? .failed) : .complete
                    
                }
            case .failed, .deleted:
                return .invalid
            }
        }
    }
    
    var isPending: Bool { return status == .pending }
    var isValid: Bool { return status != .invalid }

    var direction: TransferDirection {
        return transfer.direction
    }
    
    // MARK: Metadata
    
    private(set) var metaData: TxMetaData?
    
    var comment: String? { return metaData?.comment }
    var gift: Gift? { return metaData?.gift }
    
    private var metaDataKey: String? {
        if currency.isTezos {
            guard let reversedData = hash.data(using: .utf8)?.reversed() else { return nil }
            let hash = Data(reversedData).sha256.hexString
            return "txn2-\(hash)"
        } else {
            // The hash is a hex string, it was previously converted to bytes through UInt256
            // which resulted in a reverse-order byte array due to UInt256 being little-endian.
            // Reverse bytes to maintain backwards-compatibility with keys derived using the old scheme.
            guard let sha256hash = Data(hexString: hash, reversed: true)?.sha256.hexString else { return nil }
            //TODO:CRYPTO_V2 generic tokens
            return currency.isERC20Token ? "tkxf-\(sha256hash)" : "txn2-\(sha256hash)"
        }
    }
    
    /// Creates and stores new metadata in KV store if it does not exist
    func createMetaData(rate: Rate? = nil,
                        comment: String? = nil,
                        feeRate: Double? = nil,
                        tokenTransfer: String? = nil,
                        isReceivedGift: Bool = false,
                        gift: Gift? = nil,
                        kvStore: BRReplicatedKVStore) {
        guard metaData == nil, let key = metaDataKey else { return }
        self.metaData = TxMetaData.create(forTransaction: self,
                                          key: key,
                                          rate: rate,
                                          comment: comment,
                                          feeRate: feeRate,
                                          tokenTransfer: tokenTransfer,
                                          isReceivedGift: isReceivedGift,
                                          gift: gift,
                                          kvStore: kvStore)
    }
    
    /// Updates existing metadata with comment. Creates new metadata with comment + rate if needed
    func save(comment: String, kvStore: BRReplicatedKVStore) {
        if let metaData = metaData, let newMetaData = metaData.save(comment: comment, kvStore: kvStore) {
            self.metaData = newMetaData
        } else {
            let rate = currency.state?.currentRate
            createMetaData(rate: rate, comment: comment, kvStore: kvStore)
        }
    }
    
    func updateGiftStatus(gift: Gift, kvStore: BRReplicatedKVStore) {
        guard let metaData = metaData, let newMetaData = metaData.updateGift(gift: gift, kvStore: kvStore) else { return }
        self.metaData = newMetaData
    }
    
    var extraAttribute: String? {
        guard let key = currency.attributeDefinition?.key else { return nil }
        guard let attribute = transfer.attributes.first(where: { $0.key == key }) else { return nil }
        return attribute.value
    }

    // MARK: Init

    init(transfer: WalletKit.Transfer, wallet: Wallet, kvStore: BRReplicatedKVStore?, rate: Rate?) {
        self.transfer = transfer
        self.wallet = wallet
        
        if let kvStore = kvStore, let metaDataKey = metaDataKey {
            // load existing metadata if found
            self.metaData = TxMetaData(txKey: metaDataKey, store: kvStore)
            // create metadata for incoming transactions
            // Sender creates metadata for outgoing transactions
            if self.metaData == nil, direction == .received {
                // only set rate if recently confirmed to ensure a relatively recent exchange rate is applied
                createMetaData(rate: (status == .complete) ? nil : rate, kvStore: kvStore)
            }
        }
    }
}

// MARK: - Hashable

extension Transaction: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(transfer.hash)
    }
}

// MARK: - Equatable

func == (lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.hash == rhs.hash &&
        lhs.status == rhs.status &&
        lhs.comment == rhs.comment &&
        lhs.gift == rhs.gift
}

func == (lhs: [Transaction], rhs: [Transaction]) -> Bool {
    return lhs.elementsEqual(rhs, by: ==)
}

func != (lhs: [Transaction], rhs: [Transaction]) -> Bool {
    return !lhs.elementsEqual(rhs, by: ==)
}
