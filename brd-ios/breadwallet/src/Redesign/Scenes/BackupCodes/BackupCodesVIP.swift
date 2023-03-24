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
}

protocol BackupCodesActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol BackupCodesResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol BackupCodesDataStore: BaseDataStore, FetchDataStore {
}

protocol BackupCodesDataPassing {
    var dataStore: BackupCodesDataStore? { get }
}

protocol BackupCodesRoutes: CoordinatableRoutes {
}
