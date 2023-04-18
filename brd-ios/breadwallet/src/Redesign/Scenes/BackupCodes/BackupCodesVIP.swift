//
//  BackupCodesVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 23.3.23.
//
//

import UIKit

extension Scenes {
    static let BackupCodes = BackupCodesViewController.self
}

protocol BackupCodesViewActions: BaseViewActions, FetchViewActions {
    func getBackupCodes(viewAction: BackupCodesModels.BackupCodes.ViewAction)
}

protocol BackupCodesActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol BackupCodesResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol BackupCodesDataStore: BaseDataStore, FetchDataStore {
}

protocol BackupCodesDataPassing {
    var dataStore: (any BackupCodesDataStore)? { get }
}

protocol BackupCodesRoutes: CoordinatableRoutes {
}
