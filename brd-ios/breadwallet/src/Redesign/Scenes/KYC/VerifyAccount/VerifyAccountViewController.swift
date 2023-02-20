//
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

extension Scenes {
    static let VerifyAccount = VerifyAccountViewController.self
}

class VerifyAccountViewController: BaseInfoViewController {
    var flow: ProfileModels.ExchangeFlow?
    var didTapBackToHomeButton: (() -> Void)?
    var didTapContactSupportButton: (() -> Void)?
    
    override var imageName: String? { return Asset.verification.name }
    override var titleText: String? { return L10n.Account.verifyAccountTitle }
    override var descriptionText: String? { return L10n.Account.verifyAccountDescription }
    override var buttonViewModels: [ButtonViewModel] {
        return [
            .init(title: L10n.Swap.backToHome, callback: { [weak self] in
                self?.shouldDismiss = true
                self?.didTapBackToHomeButton?()
            }),
            .init(title: L10n.ComingSoon.Buttons.contactSupport, isUnderlined: true, callback: { [weak self] in
                self?.didTapContactSupportButton?()
            })
        ]
    }
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
}
