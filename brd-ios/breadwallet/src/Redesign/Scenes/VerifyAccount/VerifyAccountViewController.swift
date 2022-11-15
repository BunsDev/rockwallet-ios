// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

extension Scenes {
    static let VerifyAccount = VerifyAccountViewController.self
}

class VerifyAccountViewController: BaseInfoViewController {
    var role: CustomerRole?
    
    override var imageName: String? {
        switch role {
        case .kyc1:
            return "il_setup"
            
        case .kyc2:
            return "verification"
            
        default:
            return ""
        }
    }
    override var titleText: String? { return L10n.Account.messageVerifyAccount }
    override var descriptionText: String? {
        switch role {
        case .kyc1:
            return L10n.Account.verifyIdentity
            
        case .kyc2:
            return L10n.Account.upgradeVerificationIdentity
            
        default:
            return ""
        }
    }
    override var buttonViewModels: [ButtonViewModel] {
        return [
            .init(title: L10n.Button.verify, callback: { [weak self] in
                self?.coordinator?.showVerifications()
            }),
            .init(title: L10n.Button.maybeLater, isUnderlined: true, callback: { [weak self] in
                self?.coordinator?.goBack(completion: {})
            })
        ]
    }
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
}
