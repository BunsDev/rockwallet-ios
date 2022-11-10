// 
//  FESegmentControl.swift
//  breadwallet
//
//  Created by Rok on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct SegmentControlConfiguration: Configurable {
    var font: UIFont = Fonts.button
    var normal: BackgroundConfiguration = .init(backgroundColor: LightColors.Background.cards, tintColor: LightColors.primary)
    var selected: BackgroundConfiguration = .init(backgroundColor: LightColors.primary, tintColor: LightColors.Contrast.two)
}

struct SegmentControlViewModel: ViewModel {
    /// Passing 'nil' leaves the control deselected
    var selectedIndex: FESegmentControl.Values?
}

class FESegmentControl: UISegmentedControl, ViewProtocol {
    enum Values: String, CaseIterable {
        case card
        case ach
    }
    
    var config: SegmentControlConfiguration?
    var viewModel: SegmentControlViewModel?
    
    var didChangeValue: ((Values) -> Void)?
    
    convenience init() {
        let items = [
            "BUY WITH CARD",
            "FUND WITH ACH"
        ]
        
        self.init(items: items)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
        clipsToBounds = true
        
        if subviews.indices.contains(selectedSegmentIndex),
            let foregroundImageView = subviews[numberOfSegments] as? UIImageView {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: 10, dy: 10)
            foregroundImageView.image = UIImage.imageForColor(LightColors.primary)
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.layer.cornerRadius = foregroundImageView.frame.height / 2
            foregroundImageView.backgroundColor = .white
        }
    }
    
    func configure(with config: SegmentControlConfiguration?) {
        guard let config = config else { return }
        
        snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.Common.defaultCommon.rawValue)
        }
        
        backgroundColor = config.normal.backgroundColor
        selectedSegmentTintColor = config.selected.backgroundColor
        
        setTitleTextAttributes([
            .font: config.font,
            .foregroundColor: config.normal.tintColor
        ], for: .normal)
        
        setTitleTextAttributes([
            .font: config.font,
            .foregroundColor: config.selected.tintColor
        ], for: .selected)
        
        valueChanged = { [weak self] in
            guard let selectedSegmentIndex = self?.selectedSegmentIndex, selectedSegmentIndex >= 0 else { return }
            self?.didChangeValue?(Values.allCases[selectedSegmentIndex])
        }
    }
    
    func setup(with viewModel: SegmentControlViewModel?) {
        guard let index = viewModel?.selectedIndex,
              let filteredIndex = Values.allCases.firstIndex(where: { $0 == index }) else {
            selectedSegmentIndex = UISegmentedControl.noSegment
            return
        }
        
        selectedSegmentIndex = filteredIndex
    }
}
