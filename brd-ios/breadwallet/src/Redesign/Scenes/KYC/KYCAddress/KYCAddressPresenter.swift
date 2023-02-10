//
//  KYCAddressPresenter.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

final class KYCAddressPresenter: NSObject, Presenter, KYCAddressActionResponses {
    typealias Models = KYCAddressModels

    weak var viewController: KYCAddressViewController?

    // MARK: - KYCAddressActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        var sections: [Models.Section] = [
            .mandatory,
            .address,
            .country,
            .cityAndState,
            .postalCode,
            .confirm
        ]
        
        let trailingModel: ImageViewModel? = item.country == C.countryUS ? .image(Asset.chevronDown.image) : nil
        
        if item.country == C.countryUS {
            sections.insert(.ssn, at: 5)
            sections.insert(.ssnInfo, at: 6)
        }
        
        let sectionRows: [Models.Section: [Any]] = [
            .mandatory: [LabelViewModel.text(L10n.Account.mandatoryFields)],
            .address: [
                TextFieldModel(title: "\(L10n.Buy.address)*",
                               value: item.address)
            ],
            .country: [
                TextFieldModel(title: L10n.Account.countryRegion,
                               value: item.countryFullName,
                               trailing: .image(Asset.chevronDown.image))
            ],
            .cityAndState: [
                DoubleHorizontalTextboxViewModel(primary: .init(title: L10n.Account.city,
                                                                value: item.city),
                                                 secondary: .init(title: L10n.Buy.stateProvince,
                                                                  value: item.stateName,
                                                                  trailing: trailingModel))
            ],
            .postalCode: [
                TextFieldModel(title: L10n.Account.postalCode,
                               value: item.postalCode)
            ],
            .ssn: [
                TextFieldModel(title: L10n.Account.socialSecurityNumber,
                               value: item.ssn)
            ],
            .ssnInfo: [HorizontalButtonsViewModel(buttons: [ButtonViewModel(title: L10n.Account.infoLinkSSN,
                                                                            isUnderlined: true)])
            ],
            .confirm: [
                ButtonViewModel(title: L10n.Button.confirm, enabled: item.isValid)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentForm(actionResponse: KYCAddressModels.FormUpdated.ActionResponse) {
        viewController?.displayForm(responseDisplay: .init(isValid: actionResponse.isValid ?? false))
    }
    
    func presentExternalKYC(actionResponses: KYCAddressModels.ExternalKYC.ActionResponse) {
        guard let address = actionResponses.address else { return }
        viewController?.displayExternalKYC(responseDisplay: .init(address: address))
    }
    
    func presentSsnInfo(actionResponse: KYCAddressModels.SsnInfo.ActionResponse) {
        let model = PopupViewModel(title: .text(L10n.Account.socialSecurityNumber),
                                   body: L10n.Account.explanationSSN)
        
        viewController?.displaySsnInfo(responseDisplay: .init(model: model))
    }
    
    func presentState(actionResponse: CountriesAndStatesModels.SelectState.ActionResponse) {
        guard let states = actionResponse.states else { return }
        viewController?.displayStates(responseDisplay: .init(states: states))
    }

    // MARK: - Additional Helpers

}
