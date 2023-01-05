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
            .title: [LabelViewModel.text(L10n.RecoveryKeyFlow.title)],
            .image: [ImageViewModel.photo(Asset.recoveryPhrase1st.image)],
            .writePhrase: [FETitleSubtitleViewViewModel(title: .text(L10n.RecoveryKeyFlow.WritePhrase.title),
                                                        subtitle: .text(L10n.RecoveryKeyFlow.WritePhrase.subtitle))],
            .keepPhrasePrivate: [FETitleSubtitleViewViewModel(title: .text(L10n.RecoveryKeyFlow.KeepPhrasePrivate.title),
                                                              subtitle: .text(L10n.RecoveryKeyFlow.KeepPhrasePrivate.subtitle))],
            .storePhraseSecurely: [FETitleSubtitleViewViewModel(title: .text(L10n.RecoveryKeyFlow.StorePhraseSecurely.title),
                                                                subtitle: .text(L10n.RecoveryKeyFlow.StorePhraseSecurely.subtitle))],
            .tickbox: [TickboxItemViewModel(title: .text(L10n.RecoveryKeyFlow.Tickbox.value))]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentToggleTickbox(actionResponse: RecoveryKeyIntroModels.Tickbox.ActionResponse) {
        viewController?.displayToggleTickbox(responseDisplay: .init(model: .init(title: L10n.Button.continueAction, enabled: actionResponse.value)))
    }
    
    // MARK: - Additional Helpers
    
}
