//
//  SellCoordinator.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

class SellCoordinator: BaseCoordinator, SellRoutes {
    
    // MARK: - SellRoutes
    func showOrderPreview(crypto: Amount?,
                          quote: Quote?,
                          payment: PaymentCard?) {
        open(scene: Scenes.OrderPreview) { vc in
            vc.dataStore?.quote = quote
            vc.dataStore?.to = crypto
            vc.dataStore?.from = crypto?.fiatValue
            vc.dataStore?.card = payment
            vc.prepareData()
        }
    }

    // MARK: - Aditional helpers
    
}
