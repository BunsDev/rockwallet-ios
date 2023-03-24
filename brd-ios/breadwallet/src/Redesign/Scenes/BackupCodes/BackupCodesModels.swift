//
//  BackupCodesModels.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 23.3.23.
//
//

import UIKit

enum BackupCodesModels {
    typealias Item = BackupCodesDataStore
    
    enum Section: Sectionable {
        case instructions
        case description
        case backupCodes
        case getNewCodes
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
}
