//
//  AssetDetailsFooterView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import Combine
import UIKit

enum AssetDetailsFooterAction {
    case send, receive, buySell, swap
}

class AssetDetailsFooterView: UIView, Subscriber {
    
    static let height: CGFloat = 72.0
    
    private let actionSubject = PassthroughSubject<AssetDetailsFooterAction, Never>()
    var actionPublisher: AnyPublisher<AssetDetailsFooterAction, Never> {
        actionSubject.eraseToAnyPublisher()
    }
    
    private var hasSetup = false
    private let currency: Currency
    
    init(currency: Currency) {
        self.currency = currency
        super.init(frame: .zero)
        setup()
    }

    private func toRadian(value: Int) -> CGFloat {
        return CGFloat(Double(value) / 180.0 * .pi)
    }
    
    private func setup() {
        let separator = UIView(color: LightColors.Outline.one)
        addSubview(separator)
        backgroundColor = LightColors.Background.one
        separator.constrainTopCorners(height: 0.5)
        layer.cornerRadius = CornerRadius.large.rawValue
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        setupToolbarButtons()
    }
    
    private func setupToolbarButtons() {
        let buttons = [
            (Asset.send.image, #selector(send(_:))),
            (Asset.receive.image, #selector(receive(_:))),
            (Asset.buySell.image, #selector(buySell(_:))),
            (Asset.trade.image, #selector(swap(_:)))
        ].compactMap { (image, selector) -> BRDButton in
            let button = BRDButton(title: nil, type: .secondary, image: image)
            button.addTarget(self, action: selector, for: .touchUpInside)
            return button
        }
        let buttonsView = UIStackView(arrangedSubviews: buttons)
        buttonsView.spacing = Margins.small.rawValue
        buttonsView.distribution = .equalSpacing
        
        let bottomMargin: Margins = UIDevice.current.hasNotch ? .extraHuge : .medium
        
        addSubview(buttonsView)
        buttonsView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Margins.medium.rawValue)
            make.height.equalTo(ViewSizes.Common.defaultCommon.rawValue)
            make.leading.equalToSuperview().offset(Margins.huge.rawValue)
            make.trailing.equalToSuperview().offset(-Margins.huge.rawValue)
            make.bottom.equalToSuperview().inset(bottomMargin.rawValue)
        }
        
        buttons.forEach { button in
            button.snp.makeConstraints { make in
                make.width.equalTo(button.snp.height).priority(.required)
            }
        }
    }

    @objc private func send(_ sender: UIButton) { actionSubject.send(.send) }
    @objc private func receive(_ sender: UIButton) { actionSubject.send(.receive) }
    @objc private func buySell(_ sender: UIButton) { actionSubject.send(.buySell) }
    @objc private func swap(_ sender: UIButton) { actionSubject.send(.swap) }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}
