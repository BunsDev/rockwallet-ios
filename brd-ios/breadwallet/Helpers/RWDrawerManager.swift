//
//  RWDrawerManager.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 12/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class RWDrawerManager: NSObject {
    private var viewController: UIViewController?
    private let drawer = RWDrawer()
    
    var drawerIsShown: Bool {
        return drawer.isShown
    }
    
    func setupDrawer(on viewController: UIViewController,
                     config: DrawerConfiguration,
                     viewModel: DrawerViewModel,
                     callbacks: [(() -> Void)],
                     dismissSetup: ((RWDrawer) -> Void)?) {
        self.viewController = viewController
        
        drawer.callbacks = callbacks
        drawer.configure(with: config)
        drawer.setup(with: viewModel)
        viewController.view.addSubview(drawer)
        
        drawer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-ViewSizes.extraExtraHuge.rawValue)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        dismissSetup?(drawer)
    }
    
    func toggleDrawer() {
        drawer.toggle()
    }
    
    func hideDrawer() {
        drawer.hide()
    }
}
