//
//  EnterCodeView.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum AuthenticatorAppModels {
    enum Section: Sectionable {
        case instructions
        case qrCode
        case enterCodeManually
        case copyCode
        case description
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
}
