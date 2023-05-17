// 
//  ComingSoonViewController.swift
//  breadwallet
//
//  Created by Rok on 15/11/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let ComingSoon = ComingSoonViewController.self
}

class ComingSoonViewController: BaseInfoViewController {
    var reason: BaseInfoModels.ComingSoonReason? {
        didSet {
            prepareData()
        }
    }
    
    override var imageName: String? { return reason?.iconName }
    override var titleText: String? {
        return dataStore?.restrictionReason == .manuallyConfigured ? "This feature is not available for your account at this time." : reason?.title ?? ""
    }
    override var descriptionText: String? { dataStore?.restrictionReason == .manuallyConfigured ?
        reason == .swap ? L10n.ComingSoon.swapDescription : L10n.ComingSoon.buyDescription :
        reason?.description ?? "" }
    
    override var buttonViewModels: [ButtonViewModel] {
        return [
            .init(title: reason?.firstButtonTitle, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.didTapMainButton?()
            }),
            .init(title: reason?.secondButtonTitle, isUnderlined: true, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.didTapSecondayButton?()
            })
        ]
    }
    
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.KycComingSoon(type: String(describing: reason)))
    }
}
