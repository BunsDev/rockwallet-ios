//
//  VerifyPhoneNumberPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class VerifyPhoneNumberPresenter: NSObject, Presenter, VerifyPhoneNumberActionResponses {
    typealias Models = VerifyPhoneNumberModels
    
    weak var viewController: VerifyPhoneNumberViewController?
    
    // MARK: - VerifyPhoneNumberActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Section] = [
            .instructions,
            .phoneNumber
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .instructions: [
                LabelViewModel.text(L10n.VerifyPhoneNumber.instructions)
            ],
            .phoneNumber: [
                PhoneNumberViewModel(areaCode: .init(leading: .image("🇺🇸".textToImage()), title: "+1"),
                                     phoneNumber: .init(placeholder: L10n.VerifyPhoneNumber.PhoneNumber.title))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentSetAreaCode(actionResponse: VerifyPhoneNumberModels.SetAreaCode.ActionResponse) {
        let areaCode = actionResponse.areaCode
        
        viewController?.displaySetAreaCode(responseDisplay: .init(areaCode:
                .init(areaCode: .init(leading: .image(areaCode.flag.textToImage()), title: areaCode.prefix),
                      phoneNumber: .init(value: actionResponse.phoneNumber, placeholder: L10n.VerifyPhoneNumber.PhoneNumber.title))))
    }
    
    func presentValidate(actionResponse: VerifyPhoneNumberModels.Validate.ActionResponse) {
        viewController?.displayValidate(responseDisplay: .init(isValid: actionResponse.isValid))
    }
    
    func presentConfirm(actionResponse: VerifyPhoneNumberModels.Confirm.ActionResponse) {
        viewController?.displayConfirm(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers
    
}
