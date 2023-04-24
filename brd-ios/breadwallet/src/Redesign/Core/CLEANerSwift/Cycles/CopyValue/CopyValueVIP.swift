// 
//  CopyValueVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 24.4.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import UIKit

protocol CopyValueActions {
    func copyValue(viewAction: CopyValueModels.Copy.ViewAction)
}

protocol CopyValueResponses {
    func presentCopyValue(actionResponse: CopyValueModels.Copy.ActionResponse)
}

extension Interactor where Self: CopyValueActions,
                           Self.ActionResponses: CopyValueResponses {
    func copyValue(viewAction: CopyValueModels.Copy.ViewAction) {
        let value = viewAction.value?.filter { !$0.isWhitespace } ?? ""
        UIPasteboard.general.string = value
        
        presenter?.presentCopyValue(actionResponse: .init())
    }
}

extension Presenter where Self: CopyValueResponses {
    func presentCopyValue(actionResponse: CopyValueModels.Copy.ActionResponse) {
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(L10n.Receive.copied)),
                                                              config: Presets.InfoView.verification))
    }
}
