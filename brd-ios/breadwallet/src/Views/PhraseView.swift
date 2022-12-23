//
//  PhraseView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-26.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class PhraseView: UIView {

    private let phrase: String
    private let label = UILabel()

    static let defaultSize = CGSize(width: 128.0, height: 88.0)

    var xConstraint: NSLayoutConstraint?

    init(phrase: String) {
        self.phrase = phrase
        super.init(frame: CGRect())
        setupSubviews()
    }

    private func setupSubviews() {
        addSubview(label)
        label.constrain(toSuperviewEdges: UIEdgeInsets(top: Margins.small.rawValue,
                                                       left: Margins.large.rawValue,
                                                       bottom: -Margins.small.rawValue,
                                                       right: -Margins.large.rawValue))
        label.textColor = .black
        label.text = phrase
        label.font = Fonts.Subtitle.one
        label.textAlignment = .center
        backgroundColor = LightColors.Error.two
        layer.cornerRadius = 10.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
