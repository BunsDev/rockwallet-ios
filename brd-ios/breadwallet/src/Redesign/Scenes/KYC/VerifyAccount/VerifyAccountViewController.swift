//
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

extension Scenes {
    static let VerifyAccount = VerifyAccountViewController.self
}

class VerifyAccountViewController: BaseInfoViewController {
    var flow: ProfileModels.ExchangeFlow?
    
    override var imageName: String? {
        switch flow {
        case .swap:
            return Asset.ilSetup.name
            
        case .buy:
            return Asset.verification.name
            
        default:
            return ""
        }
    }
    override var titleText: String? { return L10n.Account.messageVerifyAccount }
    override var descriptionText: String? {
        switch flow {
        case .swap:
            return L10n.Account.verifyIdentity(L10n.HomeScreen.trade.lowercased())
            
        case .buy:
            return L10n.Account.verifyIdentity(L10n.HomeScreen.buy.lowercased())
            
        default:
            return L10n.Account.upgradeVerificationIdentity
        }
    }
    override var buttonViewModels: [ButtonViewModel] {
        return [
            .init(title: L10n.Button.verify, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.coordinator?.showAccountVerification()
            }),
            .init(title: L10n.Button.maybeLater, isUnderlined: true, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.coordinator?.dismissFlow()
            })
        ]
    }
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
}
