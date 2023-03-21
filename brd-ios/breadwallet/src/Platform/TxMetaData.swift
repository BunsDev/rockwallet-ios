//
//  BRKVStoreObjects.swift
//  BreadWallet
//
//  Created by Samuel Sutch on 8/13/16.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import Foundation

/// Stores additional information about a given transaction
final class TxMetaData: BRKVStoreObject, Codable {
    var classVersion: Int = 4
    
    var blockHeight: Int = 0
    var exchangeRate: Double = 0
    var exchangeRateCurrency: String = ""
    var feeRate: Double = 0
    var size: Int = 0
    var created: Date = Date.zeroValue()
    var deviceId: String = ""
    var comment = ""
    var tokenTransfer = ""
    var isReceivedGift: Bool = false
    var gift: Gift?
    
    enum CodingKeys: String, CodingKey {
        case classVersion
        case blockHeight = "bh"
        case exchangeRate = "er"
        case exchangeRateCurrency = "erc"
        case feeRate = "fr"
        case size = "s"
        case deviceId = "dId"
        case created = "c"
        case comment = "comment"
        case tokenTransfer = "tokenTransfer"
        case isReceivedGift = "isReceivedGift"
        case gift = "gift"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        classVersion = try container.decode(Int.self, forKey: .classVersion)
        if classVersion == Int.zeroValue() {
            throw BRReplicatedKVStoreError.malformedData
        }
        blockHeight = try container.decode(Int.self, forKey: .blockHeight)
        exchangeRate = try container.decode(Double.self, forKey: .exchangeRate)
        exchangeRateCurrency = try container.decode(String.self, forKey: .exchangeRateCurrency)
        feeRate = try container.decode(Double.self, forKey: .feeRate)
        size = try container.decode(Int.self, forKey: .size)
        deviceId = try container.decode(String.self, forKey: .deviceId)
        created = try container.decode(Date.self, forKey: .created)
        comment = try container.decode(String.self, forKey: .comment)
        
        // No support for gifting yet.
//        if !comment.isEmpty {
//            print("[gifting] error: \(comment)")
//        }
        
        //tokenTransfer is sometimes not present in TxMetaData from Android so we shouldn't throw if it doesn't exist
        tokenTransfer = (try? container.decode(String.self, forKey: .tokenTransfer)) ?? ""
        isReceivedGift = (try? container.decode(Bool.self, forKey: .isReceivedGift)) ?? false
        
        // No support for gifting yet.
//        do {
//            gift = try container.decode(Gift.self, forKey: .gift)
//        } catch let e {
//            print("[gifting] error: \(e)")
//        }
        
        super.init(key: "", version: 0, lastModified: Date(), deleted: true, data: Data())
    }

    /// Find metadata object based on the txKey
    public init?(txKey: String, store: BRReplicatedKVStore) {
        var ver: UInt64
        var date: Date
        var del: Bool
        var bytes: [UInt8]

        //print("[BRTxMetadataObject] find \(txKey)")
        do {
            (ver, date, del, bytes) = try store.get(txKey)
            let bytesDat = Data(bytes: &bytes, count: bytes.count)
            super.init(key: txKey, version: ver, lastModified: date, deleted: del, data: bytesDat)
            return
        } catch _ {
            //print("[BRTxMetadataObject] Unable to initialize BRTxMetadataObject: \(String(describing: e))")
        }

        return nil
    }
    
    /// Create new transaction metadata
    init(key: String,
         transaction: Transaction,
         exchangeRate: Double?,
         exchangeRateCurrency: String?,
         feeRate: Double?,
         deviceId: String,
         comment: String?,
         tokenTransfer: String?,
         isReceivedGift: Bool = false,
         gift: Gift? = nil) {
        print("[TxMetaData] new \(key) \(transaction.created?.description ?? "now")")
        super.init(key: key,
                   version: 0,
                   lastModified: Date(),
                   deleted: false,
                   data: Data())
        self.blockHeight = Int(transaction.blockHeight)
        self.created = Date()
        
        self.exchangeRate = exchangeRate ?? 0.0
        self.exchangeRateCurrency = exchangeRateCurrency ?? ""
        self.feeRate = feeRate ?? 0
        
        self.deviceId = deviceId
        self.comment = comment ?? ""
        
        if transaction.currency.isBitcoinCompatible, let feeBasis = transaction.feeBasis {
            self.size = Int(feeBasis.costFactor)
        }

        self.tokenTransfer = tokenTransfer ?? ""
        self.isReceivedGift = isReceivedGift
        self.gift = gift
    }
    
    override func getData() -> Data? {
        return BRKeyedArchiver.archiveData(withRootObject: self)
    }
    
    override func dataWasSet(_ value: Data) {
        guard !value.isEmpty else { return }
        guard let s: TxMetaData = BRKeyedUnarchiver.unarchiveObject(withData: value) else {
            print("[TxMetaData] unable to deserialize tx metadata")
            return
        }
        blockHeight = s.blockHeight
        exchangeRate = s.exchangeRate
        exchangeRateCurrency = s.exchangeRateCurrency
        feeRate = s.feeRate
        size = s.size
        created = s.created
        deviceId = s.deviceId
        comment = s.comment
        tokenTransfer = s.tokenTransfer
        isReceivedGift = s.isReceivedGift
        gift = s.gift
    }
    
    // MARK: -

    static func create(forTransaction tx: Transaction,
                       key: String,
                       rate: Rate?,
                       comment: String?,
                       feeRate: Double?,
                       tokenTransfer: String?,
                       isReceivedGift: Bool,
                       gift: Gift?,
                       kvStore: BRReplicatedKVStore) -> TxMetaData {
        let newData = TxMetaData(key: key,
                                 transaction: tx,
                                 exchangeRate: rate?.rate,
                                 exchangeRateCurrency: rate?.code,
                                 feeRate: feeRate ?? 0.0,
                                 deviceId: UserDefaults.deviceID,
                                 comment: comment,
                                 tokenTransfer: tokenTransfer,
                                 isReceivedGift: isReceivedGift,
                                 gift: gift)
        do {
            print("[gifting] create tx metadata: \(gift != nil)")
            _ = try kvStore.set(newData)
        } catch let error {
            print("[TxMetaData] could not create metadata: \(error)")
        }
        return newData
    }
    
    func save(comment: String, kvStore: BRReplicatedKVStore) -> TxMetaData? {
        self.comment = comment
        do {
            return try kvStore.set(self) as? TxMetaData
        } catch let error {
            print("[TxMetaData] could not update metadata: \(error)")
            return nil
        }
    }
    
    func updateGift(gift: Gift, kvStore: BRReplicatedKVStore) -> TxMetaData? {
        self.gift = gift
        do {
            print("[gifting] updated tx metadata")
            return try kvStore.set(self) as? TxMetaData
        } catch let error {
            print("[gifting] could not update metadata: \(error)")
            return nil
        }
    }
}
