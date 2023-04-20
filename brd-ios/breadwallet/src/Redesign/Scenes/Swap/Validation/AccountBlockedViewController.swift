// 
//  AccountBlockedViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let AccountBlocked = AccountBlockedViewController.self
}

class AccountBlockedViewController: BaseInfoViewController {
    override var imageName: String? { return Asset.unlockWalletDisabled.name }
    override var titleText: String? { return "Your RockWallet account is currently disabled." }
    override var descriptionText: String? { return """
It appears that you're unable to verify your account. For security reasons, we have temporarily disabled it.

Don't worry, your data is safe, and you can still access your self-custodial funds from your homepage. For more information, please contact support.
""" }
    override var buttonViewModels: [ButtonViewModel] {
        return [
            .init(title: "BACK TO HOME PAGE", callback: { [weak self] in
                self?.didTapMainButton?()
            }),
            .init(title: "Contact support", isUnderlined: true, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.didTapSecondayButton?()
            })
        ]
    }
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
}
