//
//  TxListViewModel.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 28/05/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

/// View model of a transaction in list view
struct TxListViewModel: TxViewModel, Hashable {
    
    // MARK: - Properties
    
    var tx: Transaction?
    var exchange: ExchangeDetail?
    var id: Int? {
        return tx?.swapOrderId ?? exchange?.orderId
    }
    
    func amount(showFiatAmounts: Bool, rate: Rate) -> String {
        if let tx = tx {
            var amount = tx.amount

            // This is the originating tx of a token transfer, so the amount is 0 but we want to show the fee
            if tokenTransferCode != nil {
                amount = tx.fee
            }

            let text = Amount(amount: amount,
                              rate: showFiatAmounts ? rate : nil,
                              negative: (tx.direction == .sent)).description
            return text
        } else if let exchange = exchange {
            let amount: String
            var destination: ExchangeDetail.SourceDestination?
            
            if let part = exchange.part {
                if exchange.destination?.part == part {
                    destination = exchange.destination
                } else if exchange.instantDestination?.part == part {
                    destination = exchange.instantDestination
                }
            } else {
                if exchange.destination?.transactionId != nil {
                    destination = exchange.destination
                } else if exchange.instantDestination?.transactionId != nil {
                    destination = exchange.instantDestination
                }
            }
            
            amount = ExchangeFormatter.current.string(for: destination?.currencyAmount) ?? ""
            
            return "\(amount) \(String(describing: destination?.currency ?? ""))"
        } else {
            return .init()
        }
    }
    
    func shortDescription(for currency: Currency) -> String {
        switch exchangeType {
        case .unknown:
            return handleDefaultTransactions()
            
        case .swap:
            return handleSwapTransactions(for: currency)
            
        case .sell:
            return handleSellTransactions()
            
        case .buyAch, .buyCard, .instantAch:
            return handleBuyTransactions()
            
        }
    }
    
    private func handleDefaultTransactions() -> String {
        guard let tx = tx else { return "" }
        
        switch status {
        case .invalid:
            return L10n.Transaction.failed
            
        case .complete:
            if tx.direction == .sent {
                return L10n.TransactionDetails.sent(tx.toAddress)
            } else if tx.direction == .received {
                return L10n.TransactionDetails.received(tx.fromAddress)
            }
            return ""
            
        default:
            guard let currency = currency else { return "" }
            return "\(confirmations)/\(currency.confirmationsUntilFinal) " + L10n.TransactionDetails.confirmationsLabel
        }
    }
    
    private func handleBuyTransactions() -> String {
        var status: TransactionStatus = status
        
        switch status {
        case .invalid, .failed, .refunded:
            status = .failed
            
        case .complete, .manuallySettled, .confirmed:
            status = .complete
            
        default:
            status = .pending
            
        }
        
        switch exchangeType {
        case .buyCard:
            switch status {
            case .pending:
                return L10n.Transaction.pendingPurchase
                
            case .complete:
                return L10n.Transaction.purchased
                
            case .failed:
                return L10n.Transaction.purchaseFailed
                
            default:
                break
            }
            
        case .buyAch, .instantAch:
            if exchange?.instantDestination?.part == .one && exchange?.isHybridTransaction == false {
                switch status {
                case .pending:
                    return L10n.Transaction.pendingPurchaseWithInstantBuy
                    
                case .complete:
                    return L10n.Transaction.purchasedWithInstantBuy
                    
                case .failed:
                    return L10n.Transaction.failedPurchaseWithInstantBuy
                    
                default:
                    break
                }
            }
            
            let isHybridPartOne = exchange?.isHybridTransaction == true && exchange?.part == .one
            
            switch status {
            case .pending:
                return isHybridPartOne ? L10n.Transaction.pendingPurchaseWithInstantBuy : L10n.Transaction.pendingPurchaseWithAch
                
            case .complete:
                return isHybridPartOne ? L10n.Transaction.purchasedWithInstantBuy : L10n.Transaction.purchasedWithAch
                
            case .failed:
                return isHybridPartOne ? L10n.Transaction.failedPurchaseWithInstantBuy : L10n.Transaction.purchaseFailedWithAch
                
            default:
                break
            }
            
        default:
            break
        }
        
        return ""
    }
    
    private func handleSellTransactions() -> String {
        switch status {
        case .invalid, .failed, .refunded:
            return L10n.Transaction.withdrawalFailed
    
        case .complete, .manuallySettled, .confirmed:
            return L10n.Transaction.withdrawalComplete
            
        default:
            return L10n.Transaction.pendingWithdrawWithAch
        }
    }
    
    private func handleSwapTransactions(for currency: Currency) -> String {
        let sourceCurrency = exchangeSourceCurrency?.code.uppercased() ?? ""
        let destinationCurrency = exchangeDestinationCurrency?.code.uppercased() ?? ""
        let isOnSource = currency.code.uppercased() == destinationCurrency
        let swapString = isOnSource ? "from \(sourceCurrency)" : "to \(destinationCurrency)"
        
        switch status {
        case .complete, .manuallySettled:
            return "\(L10n.Transaction.swapped) \(swapString)"
            
        case .pending:
            return "\(L10n.Transaction.pendingSwap) \(swapString)"
            
        case .failed, .refunded:
            return "\(L10n.Transaction.failedSwap) \(swapString)"
            
        default:
            return ""
        }
    }
}
