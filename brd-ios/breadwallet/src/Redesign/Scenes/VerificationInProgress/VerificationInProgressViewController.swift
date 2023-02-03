// 
//  VerificationInProgressViewController.swift
//  breadwallet
//
//  Created by Dino Gacevic on 03/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

extension Scenes {
    static let verificationInProgress = VerificationInProgressViewController.self
}

class VerificationInProgressViewController: CheckListViewController {
    
    override var sceneLeftAlignedTitle: String? { return nil }
    
    override var checklistTitle: LabelViewModel {
        let attributedText = NSAttributedString(string: "Your ID verification is in progress",
                                                attributes: [.font: Fonts.Title.five])
        return .attributedText(attributedText)
    }
    
    override var checkmarks: [ChecklistItemViewModel] {
        return [.init(title: .text("Photos processed"), image: .image(Asset.checkboxSelectedCircle.image)),
                .init(title: .text("Image quality checked"), image: .image(Asset.checkboxSelectedCircle.image)),
                .init(title: .text("Document inspected"), image: .image(Asset.checkboxSelectedCircle.image)),
                .init(title: .text("Biometrics verified"), image: .image(Asset.checkboxSelectedCircle.image)),
                addAnimatedCellModel()]
    }
    
    override var footerViewModel: LabelViewModel? {
        return .text("This may take a few minutes.")
    }
    
    private func addAnimatedCellModel() -> ChecklistItemViewModel {
        let attributedText = NSAttributedString(
            string: "Finalizing the decision",
            attributes: [.font: ThemeManager.shared.font(for: Fonts.Primary, size: 16)])
        return .init(title: .attributedText(attributedText), image: .animation("verificationLoader"))
    }
}
