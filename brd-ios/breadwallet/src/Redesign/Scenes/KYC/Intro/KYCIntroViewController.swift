//
//  KYCIntroViewController.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

extension Scenes {
    static let KYCIntro = KYCIntroViewController.self
}

class KYCIntroViewController: CheckListViewController {

    override var sceneLeftAlignedTitle: String? { return L10n.Account.letsGetVerified }
    override var checklistTitle: LabelViewModel { return .text(L10n.AccountKYCLevelTwo.beforeStart) }
    override var checkmarks: [ChecklistItemViewModel] { return [
        .init(title: .text(L10n.AccountKYCLevelTwo.prepareDocument)),
        .init(title: .text(L10n.AccountKYCLevelTwo.makeSure)),
        .init(title: .text(L10n.AccountKYCLevelTwo.takePhotos))
    ]}
    
    override var headerViewModel: LabelViewModel? {
        return .text(L10n.Account.verifyIdentityByVeriff)
    }
    
    override var footerViewModel: LabelViewModel? {
        let normal = L10n.Account.veriffTerms("")
        let special = L10n.Account.veriffPrivacyPolicy
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.Subtitle.two,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let text = NSMutableAttributedString(string: normal)
        text.append(NSAttributedString(string: special, attributes: attributes))
        return .attributedText(text)
    }
    
    override func footerTapped() {
        coordinator?.presentURL(string: C.veriffPrivacyPolicy, title: L10n.Account.veriffPrivacyPolicy)
    }
    
    override func buttonTapped() {
        UserManager.shared.refresh { [weak self] _ in
            (self?.coordinator as? KYCCoordinator)?.dismissFlow()
        }
    }
}
