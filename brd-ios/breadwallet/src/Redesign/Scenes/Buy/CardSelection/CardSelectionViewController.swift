// 
//  CardSelectionViewController.swift
//  breadwallet
//
//  Created by Rok on 02/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let CardSelection = CardSelectionViewController.self
}

class CardSelectionViewController: ItemSelectionViewController {
    override var sceneTitle: String? { return L10n.Buy.paymentMethods }
    override var isSearchEnabled: Bool { return false }
    
    var paymentCardDeleted: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.separatorStyle = .none
        
        itemDeleted = { [weak self] in
            self?.paymentCardDeleted?()
        }
    }
    
    override func tableView(_ tableView: UITableView, itemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<CardSelectionView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? PaymentCard
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            let unavailableText = model.paymentMethodStatus.unavailableText
            view.configure(with: .init())
            view.setup(with: .init(title: nil,
                                   subtitle: nil,
                                   logo: model.displayImage,
                                   cardNumber: .text(model.displayName),
                                   expiration: .text(CardDetailsFormatter.formatExpirationDate(month: model.expiryMonth, year: model.expiryYear)),
                                   errorMessage: model.paymentMethodStatus.isProblematic ? .attributedText(unavailableText) : nil))
            
            view.moreButtonCallback = { [weak self] in
                self?.interactor?.showActionSheetRemovePayment(viewAction: .init(instrumentId: model.id,
                                                                                 last4: model.last4))
            }
            
            view.errorLinkCallback = { [weak self] in
                self?.coordinator?.showPaymentMethodSupport()
            }
            
            view.setupCustomMargins(top: .zero, leading: .large, bottom: .zero, trailing: .large)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, addItemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<CardSelectionView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: .init(title: .text(L10n.Buy.card),
                                   subtitle: nil,
                                   logo: .image(Asset.card.image),
                                   cardNumber: .text(L10n.Buy.addDebitCreditCard),
                                   expiration: nil,
                                   errorMessage: nil))
            
            view.setupCustomMargins(top: .zero, leading: .large, bottom: .zero, trailing: .large)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section,
              section == Models.Section.items,
              let model = dataSource?.itemIdentifier(for: indexPath) as? PaymentCard else {
            coordinator?.open(scene: Scenes.AddCard)
            return
        }
        
        guard dataStore?.isSelectingEnabled == true, !model.paymentMethodStatus.isProblematic else { return }
        itemSelected?(model)
        
        coordinator?.dismissFlow()
    }
    
    // MARK: - Additional Helpers
}
