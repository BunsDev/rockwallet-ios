//
//  AuthenticatorAppPresenter.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class AuthenticatorAppPresenter: NSObject, Presenter, AuthenticatorAppActionResponses {
    typealias Models = AuthenticatorAppModels

    weak var viewController: AuthenticatorAppViewController?
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Section] = [
            .instructions,
            .qrCode,
            .enterCodeManually,
            .copyCode,
            .description
        ]
        // TODO: Get the code from BE
        let code = "06N6 YMJQ Q4SX 2LBI P6BS TQ2C LFYA"
        
        let sectionRows: [Models.Section: [Any]] = [
            .instructions: [
                LabelViewModel.text(L10n.Authentication.instructions)
            ],
            .qrCode: [
                ImageViewModel.photo(generateQRCode(from: code))
            ],
            .enterCodeManually: [
                EnterCodeViewModel(title: .text(L10n.Authentication.unableToScanCode),
                                   description: .text(L10n.Authentication.enterCodeManually))
            ],
            .copyCode: [
                OrderViewModel(title: "",
                               value: AuthenticatorAppPresenter.generateAttributedCopyValue(with: code, isCopyable: true),
                               isCopyable: true)
            ],
            .description: [
                LabelViewModel.text(L10n.Authentication.description)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - AuthenticatorAppActionResponses
    
    func presentCopyValue(actionResponse: AuthenticatorAppModels.CopyValue.ActionResponse) {
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(L10n.Receive.copied)),
                                                              config: Presets.InfoView.verification))
    }

    // MARK: - Additional Helpers

    private static func generateAttributedCopyValue(with value: String, isCopyable: Bool) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = Asset.copy.image.withRenderingMode(.alwaysOriginal)
        imageAttachment.bounds = CGRect(x: 0,
                                        y: -Margins.extraSmall.rawValue,
                                        width: ViewSizes.extraSmall.rawValue,
                                        height: ViewSizes.extraSmall.rawValue)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(NSAttributedString(string: value))
        
        if isCopyable {
            completeText.append(NSAttributedString(string: "  "))
            completeText.append(attachmentString)
        }
        
        return completeText
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        if let QRFilter = CIFilter(name: "CIQRCodeGenerator") {
            QRFilter.setValue(data, forKey: "inputMessage")
            guard let qrImage = QRFilter.outputImage else {return nil}
            return UIImage(ciImage: qrImage)
        }
        return nil
    }
}
