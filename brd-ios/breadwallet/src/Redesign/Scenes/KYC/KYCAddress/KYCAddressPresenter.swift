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
        let sections: [Models.Section] = [
            .address,
            .cityAndZipPostal,
            .stateProvince,
            .country,
            .confirm
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .address: [
                TextFieldModel(title: L10n.Buy.address,
                               value: item.address)
            ],
            .cityAndZipPostal: [
                DoubleHorizontalTextboxViewModel(primary: .init(title: L10n.Buy.city,
                                                                value: item.city),
                                                 secondary: .init(title: L10n.Buy.zipPostalCode,
                                                                  value: item.postalCode))
            ],
            .stateProvince: [
                TextFieldModel(title: L10n.Buy.stateProvince,
                               value: item.state)
            ],
            .country: [
                TextFieldModel(title: L10n.Account.country,
                               value: item.countryFullName,
                               trailing: .image(Asset.chevronDown.image))
            ],
            .confirm: [
                ButtonViewModel(title: L10n.Button.confirm, enabled: item.isValid)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - Additional Helpers

}
