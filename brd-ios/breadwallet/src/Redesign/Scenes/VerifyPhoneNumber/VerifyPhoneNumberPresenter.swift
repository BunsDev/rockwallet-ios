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
import PhoneNumberKit

final class VerifyPhoneNumberPresenter: NSObject, Presenter, VerifyPhoneNumberActionResponses {
    typealias Models = VerifyPhoneNumberModels
    
    weak var viewController: VerifyPhoneNumberViewController?
    
    // MARK: - VerifyPhoneNumberActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Section] = [
            .instructions,
            .phoneNumber
        ]
        
        let phoneNumberKit = PhoneNumberKit()
        phoneNumberKit.allCountries().forEach({
            print(phoneNumberKit.countryCode(for: $0))
        })
        let sectionRows: [Models.Section: [Any]] = [
            .instructions: [
                LabelViewModel.text("We take security seriously. Providing a valid phone number lets us send you verification codes and account alerts to keep your wallet safe.")
            ],
            .phoneNumber: [
                PhoneNumberViewModel(areaCode: .init(leading: .imageName("VISA"), title: "+1"), phoneNumber: .init(placeholder: "Phone number"))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentConfirm(actionResponse: VerifyPhoneNumberModels.Confirm.ActionResponse) {
        viewController?.displayConfirm(responseDisplay: .init())
    }
    
    func presentResend(actionResponse: VerifyPhoneNumberModels.Resend.ActionResponse) {
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(L10n.AccountCreation.codeSent)),
                                                              config: Presets.InfoView.verification))
    }
    
    // MARK: - Additional Helpers
    
}
