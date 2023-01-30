//
//  DocumentReviewPresenter.swift
//  breadwallet
//
//  Created by Rok on 13/06/2022.
//
//

import UIKit

final class DocumentReviewPresenter: NSObject, Presenter, DocumentReviewActionResponses {
    typealias Models = DocumentReviewModels
    
    weak var viewController: DocumentReviewViewController?
    
    // MARK: - DocumentReviewActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item,
        let image = item.image else { return }
        
        let sections: [Models.Section] =  [
            .title,
            .checkmarks,
            .image,
            .buttons
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .title: [LabelViewModel.text(L10n.Account.beforeConfirm)],
            .checkmarks: item.checklist ?? [],
            .image: [ImageViewModel.photo(image)],
            .buttons: [
                HorizontalButtonsViewModel(buttons: [
                    .init(title: L10n.Account.retakePhoto),
                    .init(title: L10n.Button.confirm)
                ])
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    // MARK: - Additional Helpers
    
}
