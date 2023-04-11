//
//  FetchVIP.swift
//  
//
//  Created by Rok Cresnik on 02/12/2021.
//

import Foundation

protocol FetchViewActions: Hashable {
    func getData(viewAction: FetchModels.Get.ViewAction)
}

protocol FetchActionResponses: Hashable {
    func presentData(actionResponse: FetchModels.Get.ActionResponse)
}

protocol FetchResponseDisplays: Hashable {
    func displayData(responseDisplay: FetchModels.Get.ResponseDisplay)
}

protocol FetchDataStore: Hashable {
    var itemId: String? { get set }
}

protocol FetchDataPassing: Hashable {
    var dataStore: (any FetchDataStore)? { get }
}
