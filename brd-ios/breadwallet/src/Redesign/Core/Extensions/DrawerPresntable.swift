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
    func setupDrawer(config: DrawerConfiguration, viewModel: DrawerViewModel, callbacks: [(() -> Void)], dismissSetup: ((RWDrawer) -> Void)?)
    func toggleDrawer()
    func hideDrawer()
    var drawerIsShown: Bool { get }
}

extension UIViewController: DrawerPresentable {
    var drawerIsShown: Bool {
        guard let drawer = view.subviews.first(where: { $0 is RWDrawer }) as? RWDrawer else { return false }
        return drawer.isShown
    }
    
    func setupDrawer(config: DrawerConfiguration, viewModel: DrawerViewModel, callbacks: [(() -> Void)], dismissSetup: ((RWDrawer) -> Void)?) {
        let drawer = RWDrawer()
        drawer.callbacks = callbacks
        drawer.configure(with: config)
        drawer.setup(with: viewModel)
        view.addSubview(drawer)
        
        drawer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-ViewSizes.extraExtraHuge.rawValue)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        dismissSetup?(drawer)
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
