//
//  RWDrawer.swift
//  breadwallet
//
//  Created by Rok on 07/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Combine
import UIKit
import SnapKit

struct DrawerConfiguration: Configurable {
    var titleConfig = LabelConfiguration(font: Fonts.Subtitle.one,
                                         textColor: LightColors.secondary,
                                         textAlignment: .center)
    var background = BackgroundConfiguration(backgroundColor: LightColors.Background.two)
    var buttons = [
        Presets.Button.primary,
        Presets.Button.primary,
        Presets.Button.secondary
    ]
}

struct DrawerViewModel: ViewModel {
    var title: String? = L10n.Drawer.title
    var drawerImage: ImageViewModel? = .image(Asset.dragControl.image)
    var buttons: [ButtonViewModel] = [
        .init(title: L10n.Buy.buyWithCard, image: Asset.card.image),
        .init(title: L10n.Buy.fundWithAch, image: Asset.bank.image),
        .init(title: L10n.Button.sell, image: Asset.sell.image)
    ]
    var additionalBottomOffset: CGFloat = UIDevice.current.hasNotch ? 0 : Margins.large.rawValue
    var drawerBottomOffset = ViewSizes.bottomToolbarHeight.rawValue
}

class RWDrawer: FEView<DrawerConfiguration, DrawerViewModel>, UIGestureRecognizerDelegate {
    var callbacks: [(() -> Void)] = []
    var isShown: Bool { return blurView.alpha == 1 }
    
    private var viewTranslation = CGPoint(x: 0, y: 0)
    private let dismissActionSubject = PassthroughSubject<Void, Never>()
    var dismissActionPublisher: AnyPublisher<Void, Never> {
        dismissActionSubject.eraseToAnyPublisher()
    }
    private var drawerInitialY: CGFloat = 0.0
    
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.alpha = 0
        return view
    }()
    
    lazy var drawer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CornerRadius.large.rawValue
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()
    
    lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.huge.rawValue
        return view
    }()
    
    lazy var drawerImage: FEImageView = {
        let view = FEImageView()
        view.setup(with: .image(Asset.dragControl.image))
        return view
    }()
    
    lazy var title: WrapperView<FELabel> = {
        let view = WrapperView<FELabel>()
        return view
    }()
    
    lazy var buttonStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.small.rawValue
        view.distribution = .fillEqually
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        isUserInteractionEnabled = false
        
        content.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        content.addSubview(drawer)
        drawer.snp.makeConstraints { make in
            make.top.equalTo(content.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        drawer.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Margins.huge.rawValue)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(Margins.huge.rawValue)
            make.bottom.equalToSuperview()
        }
        stack.addArrangedSubview(drawerImage)
        drawerImage.snp.makeConstraints { make in
            make.height.equalTo(Margins.extraSmall.rawValue)
        }
        
        stack.addArrangedSubview(title)
        title.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.small.rawValue)
        }
        
        stack.addArrangedSubview(buttonStack)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:)))
        panGesture.delegate = self
        drawer.addGestureRecognizer(panGesture)
        blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(outsideTapped(_:))))
        drawerImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(outsideTapped(_:))))
    }
    
    override func configure(with config: DrawerConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        title.wrappedView.configure(with: config.titleConfig)
        drawer.backgroundColor = config.background.backgroundColor
        content.backgroundColor = nil
    }
    
    override func setup(with viewModel: DrawerViewModel?) {
        guard let viewModel = viewModel, let config = config else { return }
        
        super.setup(with: viewModel)
        drawerImage.setup(with: viewModel.drawerImage)
        drawerImage.isHidden = viewModel.drawerImage == nil
        
        title.isHidden = viewModel.title == nil
        if let text = viewModel.title {
            title.wrappedView.setup(with: .text(text))
        }
        
        for ((vm, conf), callback) in zip(zip(viewModel.buttons, config.buttons), callbacks) {
            let button = FEButton()
            button.configure(with: conf)
            button.setup(with: vm)
            button.viewModel?.callback = { [weak self] in
                self?.hide()
                callback()
            }
            buttonStack.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.equalTo(ViewSizes.Common.largeCommon.rawValue)
            }
        }

        buttonStack.isHidden = viewModel.buttons.isEmpty
        
        stack.snp.updateConstraints { make in
            let bottomOffset = viewModel.drawerBottomOffset + viewModel.additionalBottomOffset
            make.bottom.equalToSuperview().inset(bottomOffset)
        }
        
        content.layoutIfNeeded()
    }
    
    var contentChanged: (() -> Void)?
    
    func show() {
        guard blurView.alpha == 0 else { return }
        isUserInteractionEnabled = true
        
        drawer.snp.removeConstraints()
        drawer.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        Self.animate(withDuration: Presets.Animation.average.rawValue) { [weak self] in
            self?.blurView.alpha = 1
            self?.drawer.layoutIfNeeded()
            self?.content.layoutIfNeeded()
            self?.layoutIfNeeded()
        }
    }
    
    func hide() {
        guard blurView.alpha == 1 else { return }
        isUserInteractionEnabled = false
        drawer.snp.removeConstraints()
        drawer.snp.makeConstraints { make in
            make.top.equalTo(content.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        Self.animate(withDuration: Presets.Animation.average.rawValue) { [weak self] in
            self?.blurView.alpha = 0
            self?.drawer.layoutIfNeeded()
            self?.content.layoutIfNeeded()
            self?.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.drawer.transform = .identity
        }

    }
    
    func toggle() {
        guard blurView.alpha == 0 else {
            return hide()
        }
        
        show()
    }
    
    @objc private func outsideTapped(_ sender: UITapGestureRecognizer) {
        hide()
        dismissActionSubject.send()
    }
    
    @objc private func onDrag(_ sender: UIPanGestureRecognizer) {
        guard let draggedView = sender.view else { return }
        
        switch sender.state {
        case .began:
            // Store the original position of the view
            drawerInitialY = draggedView.frame.origin.y
            
        case .changed:
            let translation = sender.translation(in: draggedView.superview)
            
            // Prevent dragging the view higher than the initial frame
            let newY = max(drawerInitialY + translation.y, drawerInitialY)
            guard newY > drawerInitialY else {
                Self.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.drawer.transform = .identity
                })
                return
            }
            
            viewTranslation = translation
            Self.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.drawer.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
            })
            
        case .ended:
            // Hide the view if dragged sufficiently, otherwise return to initial state
            if viewTranslation.y > 100 {
                hide()
                dismissActionSubject.send()
            } else {
                Self.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.drawer.transform = .identity
                })
            }
            
        default:
            break
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
            // Prevent dragging upwards
            let translation = recognizer.translation(in: drawer)
            return translation.y >= 0
        }
        
        return false
    }
}
