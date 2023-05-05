//
//  SwapModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

enum SwapModels {
    typealias Item = (from: Amount?, to: Amount?)
    
    enum EstimateFeeResult {
        case successFee(TransferFeeBasis)
        case successEthFee(Decimal)
        case failure(Error)
    }
    
    struct SwitchPlaces {
        struct ViewAction {}
    }
    
    struct Amounts {
        struct ViewAction {
            var fromFiatAmount: String?
            var fromCryptoAmount: String?
            var toFiatAmount: String?
            var toCryptoAmount: String?
            var handleErrors = false
        }
        
        struct ActionResponse {
            var from: Amount?
            var to: Amount?
            
            var fromFee: Amount?
            var toFee: Amount?
            
            var senderValidationResult: SenderValidationResult?
            var fromFeeAmount: Amount?
            var quote: Quote?
            
            var baseBalance: Amount?
            var minimumValue: Decimal?
            var minimumUsd: Decimal?
            var handleErrors = false
        }
    }
    
    struct SelectedAsset {
        struct ViewAction {
            var from: String?
            var to: String?
        }
    }
    
    struct Assets {
        struct ViewAction {
            var from: Bool?
            var to: Bool?
        }
        
        struct ActionResponse {
            var from: [Currency]?
            var to: [Currency]?
        }
        
        struct ResponseDisplay {
            var title: String
            var from: [Currency]?
            var to: [Currency]?
        }
    }
    
    struct Fee {
        struct ViewAction {}
        
        struct ActionResponse {
            var from: Decimal?
            var to: Decimal?
        }
        
        struct ResponseDisplay {
            var from: String?
            var to: String?
        }
    }
    
    struct ShowConfirmDialog {
        struct ViewAction {}
        
        struct ActionResponse {
            var from: Amount?
            var to: Amount?
            var quote: Quote?
            var fromFee: Amount?
            var toFee: Amount?
        }
        
        struct ResponseDisplay {
            var config: WrapperPopupConfiguration<SwapConfimationConfiguration>
            var viewModel: WrapperPopupViewModel<SwapConfirmationViewModel>
        }
    }
    
    struct AssetSelectionMessage {
        struct ViewAction {
            var selectedDisabledAsset: AssetViewModel?
        }
        
        struct ActionResponse {
            var from: Currency?
            var to: Currency?
            var selectedDisabledAsset: AssetViewModel?
        }
        
        struct ResponseDisplay {
            var model: InfoViewModel?
            var config: InfoViewConfiguration?
        }
    }
    
    struct Confirm {
        struct ViewAction {
        }
        
        struct ActionResponse {
            var from: String?
            var to: String?
            var exchangeId: String?
        }
        
        struct ResponseDisplay {
            var from: String
            var to: String
            var exchangeId: String
        }
    }
    
    struct ErrorPopup {
        struct ResponseDisplay {}
    }
    
    struct AssetInfoPopup {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {
            var popupViewModel: PopupViewModel
            var popupConfig: PopupConfiguration
        }
    }
}
