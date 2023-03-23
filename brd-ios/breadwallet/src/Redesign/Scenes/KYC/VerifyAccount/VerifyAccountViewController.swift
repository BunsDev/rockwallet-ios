//
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit

extension Scenes {
    static let VerifyAccount = VerifyAccountViewController.self
}

class VerifyAccountViewController: BaseInfoViewController {
    var flow: ProfileModels.ExchangeFlow?
    var didTapBackToHomeButton: (() -> Void)?
    var didTapContactSupportButton: (() -> Void)?
    var didTapVerifyButton: (() -> Void)?
    
    override var imageName: String? { return Asset.verification.name }
    override var titleText: String? { return L10n.Account.verifyAccountTitle }
    override var descriptionText: String? { return L10n.Account.verifyAccountDescription }
    override var buttonViewModels: [ButtonViewModel] {
        switch flow {
        case .buy, .swap:
            return [
                .init(title: L10n.Swap.backToHome, callback: { [weak self] in
                    self?.shouldDismiss = true
                    self?.navigationController?.popViewController(animated: true)
                }),
                .init(title: L10n.ComingSoon.Buttons.contactSupport, isUnderlined: true, callback: { [weak self] in
                    self?.didTapContactSupportButton?()
                })
            ]
            
        case .sell:
            return [
                .init(title: L10n.Button.verify, callback: { [weak self] in
                    self?.shouldDismiss = true
                    self?.didTapVerifyButton?()
                }),
                .init(title: L10n.Button.maybeLater, isUnderlined: true, callback: { [weak self] in
                    self?.shouldDismiss = true
                    self?.navigationController?.popViewController(animated: true)
                })
            ]
            
        default:
            return []
        }
    }
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
    override func setupCloseButton(closeAction: Selector) {}
}
