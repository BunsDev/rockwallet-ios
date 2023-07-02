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
    var currency: Currency?
    var id: Int? {
        return tx?.exchange?.orderId ?? exchange?.orderId
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
        } else if let destination = destination,
                  let currency = Store.state.currencies.first(where: { $0.code.lowercased() == destination.currency.lowercased() }) {
            let amount = Amount(tokenString: destination.currencyAmount.description, currency: currency)
            return amount.description
        } else {
            return ""
        }
    }
    
    func shortDescription() -> String {
        switch exchangeType {
        case .unknown:
            return handleDefaultTransactions()
            
        case .swap:
            return handleSwapTransactions()
            
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
            
        case .complete, .completed:
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
            
        case .complete, .completed, .manuallySettled, .confirmed:
            status = .complete
            
        default:
            status = .pending
            
        }
        
        switch exchangeType {
        case .buyCard:
            switch status {
            case .pending:
                return L10n.Transaction.pendingPurchase
                
            case .complete, .completed:
                return L10n.Transaction.purchased
                
            case .failed:
                return L10n.Transaction.purchaseFailed
                
            default:
                break
            }
            
        case .buyAch, .instantAch:
            if exchange?.isHybridTransaction == true {
                let isPartOne = destination?.part == .one
                
                switch status {
                case .pending:
                    return isPartOne ? L10n.Transaction.pendingPurchaseWithInstantBuy : L10n.Transaction.pendingPurchaseWithAch
                    
                case .complete, .completed:
                    return isPartOne ? L10n.Transaction.purchasedWithInstantBuy : L10n.Transaction.purchasedWithAch
                    
                case .failed:
                    return isPartOne ? L10n.Transaction.failedPurchaseWithInstantBuy : L10n.Transaction.purchaseFailedWithAch
                    
                default:
                    break
                }
            } else {
                switch status {
                case .pending:
                    return L10n.Transaction.pendingPurchaseWithInstantBuy
                    
                case .complete, .completed:
                    return L10n.Transaction.purchasedWithInstantBuy
                    
                case .failed:
                    return L10n.Transaction.failedPurchaseWithInstantBuy
                    
                default:
                    break
                }
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
            
        case .complete, .completed, .manuallySettled, .confirmed:
            return L10n.Transaction.withdrawalComplete
            
        default:
            return L10n.Transaction.pendingWithdrawWithAch
        }
    }
    
    private func handleSwapTransactions() -> String {
        let isOnSource = currency?.code.uppercased() == swapDestinationCurrency
        let swapString = isOnSource ? "from \(swapSourceCurrency)" : "to \(swapDestinationCurrency)"
        
        switch status {
        case .complete, .completed, .manuallySettled:
            return "\(L10n.Transaction.swapped) \(swapString)"
            
        case .pending:
            return "\(L10n.Transaction.pendingSwap) \(swapString)"
            
        case .failed, .refunded:
            return "\(L10n.Transaction.failedSwap) \(swapString)"
            
        default:
            return ""
        }
    }
    
    private var swapSourceCurrency: String {
        let sourceCurrency = exchange?.source.currency.uppercased() ?? tx?.exchange?.source.currency.uppercased()
        return sourceCurrency ?? ""
    }
    
    private var swapDestinationCurrency: String {
        let destinationCurrency = exchange?.destination?.currency.uppercased() ?? tx?.exchange?.destination?.currency.uppercased()
        return destinationCurrency ?? ""
    }
}
