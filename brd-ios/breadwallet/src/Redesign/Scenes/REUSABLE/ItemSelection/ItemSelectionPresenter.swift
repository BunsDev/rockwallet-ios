//
//  ItemSelectionPresenter.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

final class ItemSelectionPresenter: NSObject, Presenter, ItemSelectionActionResponses {
    typealias Models = ItemSelectionModels

    weak var viewController: ItemSelectionViewController?

    // MARK: - ItemSelectionActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item,
              let items = item.items,
              let isAddingEnabled = item.isAddingEnabled
        else {
            viewController?.displayData(responseDisplay: .init(sections: [], sectionRows: [:]))
            return
        }
        
        var sections = [Models.Section.items]
        if isAddingEnabled {
            sections.insert(Models.Section.addItem, at: 0)
        }
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            Models.Section.items: items,
            Models.Section.addItem: [L10n.Swap.addItem]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentActionSheetRemovePayment(actionResponse: ItemSelectionModels.ActionSheet.ActionResponse) {
        viewController?.displayActionSheetRemovePayment(responseDisplay: .init(instrumentId: actionResponse.instrumentId,
                                                                               last4: actionResponse.last4,
                                                                               actionSheetOkButton: L10n.Buy.removePaymentMethod,
                                                                               actionSheetCancelButton: L10n.Button.cancel))
    }
    
    func presentRemovePaymentPopup(actionResponse: ItemSelectionModels.RemovePaymenetPopup.ActionResponse) {
        let popupViewModel = PopupViewModel(title: .text(L10n.Buy.removeCard(actionResponse.last4)),
                                            buttons: [.init(title: L10n.Staking.remove),
                                                      .init(title: L10n.Button.cancel)],
                                            closeButton: .init(image: Asset.close.image))
        
        viewController?.displayRemovePaymentPopup(responseDisplay: .init(popupViewModel: popupViewModel,
                                                                    popupConfig: Presets.Popup.normal))
    }
    
    func presentRemovePaymentMessage(actionResponse: ItemSelectionModels.RemovePayment.ActionResponse) {
        let model = InfoViewModel(description: .text(L10n.Buy.cardRemoved), dismissType: .auto)
        let config = Presets.InfoView.verification
        
        viewController?.displayMessage(responseDisplay: .init(model: model,
                                                              config: config))
        
        viewController?.displayRemovePaymentSuccess(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers

}
