//
//  LightWeightAlert.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-06-20.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class LightWeightAlert: UIView {

    init(message: String) {
        super.init(frame: .zero)
        self.label.text = message
        setup()
    }

    let effect = UIBlurEffect(style: .dark)
    let background = UIVisualEffectView()
    let container = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark)))
    private let label = UILabel(font: Fonts.Title.six)

    private func setup() {
        addSubview(background)
        background.constrain(toSuperviewEdges: nil)
        background.contentView.addSubview(container)
        container.contentView.addSubview(label)
        container.constrain(toSuperviewEdges: nil)
        label.constrain(toSuperviewEdges: UIEdgeInsets(top: Margins.large.rawValue,
                                                       left: Margins.large.rawValue,
                                                       bottom: -Margins.large.rawValue,
                                                       right: -Margins.large.rawValue))
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
