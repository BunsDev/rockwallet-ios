// 
//  DrawerPresntable.swift
//  breadwallet
//
//  Created by Dino Gacevic on 17/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

protocol DrawerPresentable {
    var drawerBottomOffset: CGFloat? { get }
    func setupDrawer(config: DrawerConfiguration, viewModel: DrawerViewModel, actionsSetup: ((RWDrawer) -> Void)?)
    func toggleDrawer()
    func hideDrawer()
}

extension UIViewController: DrawerPresentable {
    var drawerBottomOffset: CGFloat? { return 0 }
    func setupDrawer(config: DrawerConfiguration, viewModel: DrawerViewModel, actionsSetup: ((RWDrawer) -> Void)?) {
        let drawer = RWDrawer()
        drawer.callbacks = [ { [weak self] in
            print(1)
//            self?.didTapDrawerButton(.card)
        }, { [weak self] in
            print(2)
//            self?.didTapDrawerButton(.ach)
        }]
        drawer.configure(with: config)
        drawer.setup(with: viewModel)
        view.addSubview(drawer)
        
        drawer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-ViewSizes.extraExtraHuge.rawValue)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        actionsSetup?(drawer)
        //        view.dismissActionPublisher.sink { [weak self] _ in
        //            self?.animationView.play(fromProgress: 1, toProgress: 0)
        //        }.store(in: &observers)
    }
    
    func toggleDrawer() {
        guard let drawer = view.subviews.first(where: { $0 is RWDrawer }) as? RWDrawer else { return }
        drawer.toggle()
    }
    
    func hideDrawer() {
        guard let drawer = view.subviews.first(where: { $0 is RWDrawer }) as? RWDrawer else { return }
        drawer.hide()
    }
}
