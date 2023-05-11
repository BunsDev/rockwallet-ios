//
//  TxListCell.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2018-02-19.
//  Copyright © 2018-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import SwiftUI

class TxListCell: UITableViewCell, Identifiable {

    // MARK: - Views

    private  let iconImageView: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        return view
    }()
    private let titleLabel = UILabel(font: Fonts.Subtitle.two, color: LightColors.Text.three)
    private let descriptionLabel = UILabel(font: Fonts.Body.two, color: LightColors.Text.two)
    private  let amount: UILabel = {
        let label = UILabel(font: Fonts.Subtitle.two, color: LightColors.Text.three)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private let separator = UIView(color: LightColors.Outline.one)
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView.layer.cornerRadius = iconImageView.frame.height * CornerRadius.fullRadius.rawValue
    }
    
    func setTransaction(_ viewModel: TxListViewModel, currency: Currency, showFiatAmounts: Bool, rate: Rate) {
        let status = viewModel.tx?.status ?? viewModel.swap?.status ?? .pending
        iconImageView.image = viewModel.icon?.tinted(with: status.tintColor)
        iconImageView.backgroundColor = status.backgroundColor
        
        amount.text = viewModel.amount(showFiatAmounts: showFiatAmounts, rate: rate)
        if let hybridTransaction = viewModel.hybridTransaction {
            let hybridPart: Int = hybridTransaction.rawValue
            titleLabel.text = viewModel.shortTimestamp + " - \(hybridPart)/2"
        } else {
            titleLabel.text = viewModel.shortTimestamp
        }
        descriptionLabel.text = viewModel.shortDescription(for: currency)
        
        layoutSubviews()
    }
    
    // MARK: - Private
    
    private func setupViews() {
        addSubviews()
        addConstraints()
        setupStyle()
    }
    
    private func addSubviews() {
        contentView.addSubview(iconImageView)
        iconImageView.contentMode = .center
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(amount)
        contentView.addSubview(separator)
    }
    
    private func addConstraints() {
        iconImageView.constrain([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Margins.large.rawValue),
            iconImageView.widthAnchor.constraint(equalToConstant: ViewSizes.medium.rawValue),
            iconImageView.heightAnchor.constraint(equalToConstant: ViewSizes.medium.rawValue),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        titleLabel.constrain([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.medium.rawValue),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Margins.large.rawValue)])
        descriptionLabel.constrain([
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.medium.rawValue),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: amount.leadingAnchor, constant: -Margins.large.rawValue)
        ])
        amount.constrain([
            amount.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Margins.large.rawValue),
            amount.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.medium.rawValue),
            amount.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Margins.large.rawValue)])
        separator.constrainBottomCorners(height: ViewSizes.minimum.rawValue)
    }
    
    private func setupStyle() {
        selectionStyle = .none
        backgroundColor = LightColors.Background.two
        amount.textAlignment = .right
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        descriptionLabel.lineBreakMode = .byTruncatingTail
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
