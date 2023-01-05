//
//  RecoveryKeyIntroPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 04/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class RecoveryKeyIntroPresenter: NSObject, Presenter, RecoveryKeyIntroActionResponses {
    
    typealias Models = RecoveryKeyIntroModels

    weak var viewController: RecoveryKeyIntroViewController?

    // MARK: - ProfileActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Section] =  [
            .title,
            .image,
            .writePhrase,
            .keepPhrasePrivate,
            .storePhraseSecurely,
            .tickbox
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .title: [LabelViewModel.text("Secure your wallet with your Recovery Phrase")],
            .image: [ImageViewModel.photo(Asset.recoveryPhrase1st.image)],
            .writePhrase: [FETitleSubtitleViewViewModel(title: .text("Write it down"),
                                                            subtitle: .text("Save your 12 word security phrase generated  in the next step."))],
            .keepPhrasePrivate: [FETitleSubtitleViewViewModel(title: .text("Keep it private"),
                                                              subtitle: .text("Remember that anyone with your Recovery Phrase can access your Assets."))],
            .storePhraseSecurely: [FETitleSubtitleViewViewModel(title: .text("Store it securely"),
                                                                subtitle: .text("This is the only way you’ll be able to recover your funds. RockWallet does not keep a copy."))],
            .tickbox: [TickboxItemViewModel(title: .text("I understand the importance of the Recovery Phrase."))]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentToggleTickbox(actionResponse: RecoveryKeyIntroModels.Tickbox.ActionResponse) {
        viewController?.displayToggleTickbox(responseDisplay: .init(model: .init(title: L10n.Button.continueAction, enabled: actionResponse.value)))
    }
    
    // MARK: - Additional Helpers
    
}
