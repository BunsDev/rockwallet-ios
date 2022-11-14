// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit

class VerifyAccountViewController: BaseTableViewController<KYCCoordinator,
                                   VerifyAccountInteractor,
                                   VerifyAccountPresenter,
                                   VerifyAccountStore>,
                                   VerifyAccountResponseDisplays {
    
    typealias Models = VerifyAccountModels
    
    override var isModalDismissableEnabled: Bool { return false }
    
    // MARK: - Overrides
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        verticalButtons.wrappedView.configure(with: .init(buttons: [Presets.Button.primary,
                                                                    Presets.Button.noBorders]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [.init(title: L10n.Button.verify,
                                                                      callback: { [weak self] in
            self?.buttonTapped()
        }), .init(title: L10n.Button.maybeLater,
                  isUnderlined: true,
                  callback: { [weak self] in
            self?.laterTapped()
        })
        ]))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Section {
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(vertical: .extraExtraHuge, horizontal: .large)
            
        case .title:
            cell = self.tableView(tableView, titleLabelCellForRowAt: indexPath)
            (cell as? WrapperTableViewCell<FELabel>)?.wrappedView.configure(with: .init(font: Fonts.Title.six, textColor: LightColors.Text.three, textAlignment: .center))
            cell.contentView.setupCustomMargins(vertical: .large, horizontal: .extraExtraHuge)
            
        case .description:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            (cell as? WrapperTableViewCell<FELabel>)?.wrappedView.configure(with: .init(font: Fonts.Body.two, textColor: LightColors.Text.two, textAlignment: .center))
            cell.contentView.setupCustomMargins(vertical: .large, horizontal: .extraExtraHuge)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }

    // MARK: - User Interaction
    
    override func buttonTapped() {
        super.buttonTapped()
        
        coordinator?.showVerifications()
    }

    @objc func laterTapped() {
        coordinator?.goBack(completion: {})
    }
    
    // MARK: - VerifyAccountResponseDisplay

    // MARK: - Additional Helpers
}
