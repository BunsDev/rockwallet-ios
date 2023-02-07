//
//  CheckListVIP.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//
//

import UIKit

extension Scenes {
    static let CheckList = CheckListViewController.self
}

protocol CheckListViewActions: BaseViewActions {
    func checkVerificationProgress(viewAction: CheckListModels.VerificationInProgress.ViewAction)
}

protocol CheckListActionResponses: BaseActionResponses {
    func presentVerificationProgress(actionResponse: CheckListModels.VerificationInProgress.ActionResponse)
}

protocol CheckListResponseDisplays: AnyObject, BaseResponseDisplays {
    func displayVerificationProgress(responseDisplay: CheckListModels.VerificationInProgress.ResponseDisplay)
}

protocol CheckListDataStore: BaseDataStore {
}

protocol CheckListDataPassing {
    var dataStore: CheckListDataStore? { get }
}

protocol CheckListRoutes: CoordinatableRoutes {
}
