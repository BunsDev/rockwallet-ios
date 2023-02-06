// 
//  VerificationInProgressViewController.swift
//  breadwallet
//
//  Created by Dino Gacevic on 03/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

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
                .init(title: .text("Finalizing the decision"), image: .animation(Animations.verificationInProgress.animation, .loop))]
    }
    
    override var footerViewModel: LabelViewModel? {
        return .text("This may take a few minutes.")
    }
    
    private func addAnimatedCellModel() -> ChecklistItemViewModel {
        let attributedText = NSAttributedString(
            string: "Finalizing the decision",
            attributes: [.font: ThemeManager.shared.font(for: Fonts.Primary, size: 16)])
        return .init(title: .attributedText(attributedText), image: .animation(Animations.verificationInProgress.animation, .loop))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .title:
            cell =  self.tableView(tableView, labelCellForRowAt: indexPath)
            (cell as? WrapperTableViewCell<FELabel>)?.wrappedView.configure(with: .init(font: Fonts.Title.five, textColor: LightColors.Text.three))
            
        case .checkmarks:
            cell = self.tableView(tableView, checkmarkCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, checkmarkCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<ChecklistItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? ChecklistItemViewModel else {
            return UITableViewCell()
        }
        
        var labelConfig: LabelConfiguration {
            if let rowCount = sectionRows[CheckListModels.Section.checkmarks]?.count, indexPath.row == rowCount - 1 {
                return .init(font: ThemeManager.shared.font(for: Fonts.Primary, size: 16), textColor: LightColors.Text.three)
            } else {
                return .init(font: ThemeManager.shared.font(for: Fonts.Secondary, size: 16), textColor: LightColors.Text.three)
            }
        }
        
        cell.setup { view in
            view.configure(with: .init(title: labelConfig, image: nil))
            view.setup(with: model)
            view.setupCustomMargins(horizontal: .large)
        }
        
        return cell
    }
}
