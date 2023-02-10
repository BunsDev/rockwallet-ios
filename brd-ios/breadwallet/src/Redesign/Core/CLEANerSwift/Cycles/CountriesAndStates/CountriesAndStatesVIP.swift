// 
//  CountriesAndStatesVIP.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

protocol CountriesAndStatesViewActions: FetchViewActions {
    func pickCountry(viewAction: CountriesAndStatesModels.SelectCountry.ViewAction)
}

protocol CountriesAndStatesActionResponses: FetchActionResponses {
    func presentCountry(actionResponse: CountriesAndStatesModels.SelectCountry.ActionResponse)
}

protocol CountriesAndStatesResponseDisplays: FetchResponseDisplays {
    func displayCountry(responseDisplay: CountriesAndStatesModels.SelectCountry.ResponseDisplay)
}

protocol CountriesAndStatesDataStore: FetchDataStore {
    var country: String? { get set }
    var countryFullName: String? { get set }
    var countries: [Place] { get set }
}

protocol CountriesAndStatesRoutes {
    func showCountrySelector(countries: [Place], selected: ((Place?) -> Void)?)
}

extension Interactor where Self: CountriesAndStatesViewActions,
                           Self.DataStore: CountriesAndStatesDataStore,
                           Self.ActionResponses: CountriesAndStatesActionResponses {
    
    func pickCountry(viewAction: CountriesAndStatesModels.SelectCountry.ViewAction) {
        guard viewAction.code == nil else {
            dataStore?.country = viewAction.code
            dataStore?.countryFullName = viewAction.countryFullName
            presenter?.presentData(actionResponse: .init(item: dataStore))
            
            return
        }
        
        CountriesWorker().execute(requestData: CountriesRequestData()) { [weak self] result in
            switch result {
            case .success(let data):
                self?.presenter?.presentCountry(actionResponse: .init(countries: data))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
}

extension Presenter where Self: CountriesAndStatesActionResponses,
                           Self.ResponseDisplays: CountriesAndStatesResponseDisplays {
    
    func presentCountry(actionResponse: CountriesAndStatesModels.SelectCountry.ActionResponse) {
        guard let countries = actionResponse.countries else { return }
        viewController?.displayCountry(responseDisplay: .init(countries: countries))
    }
}

extension Controller where Self: CountriesAndStatesResponseDisplays,
                           Self.ViewActions: CountriesAndStatesViewActions,
                           Self.Coordinator: CountriesAndStatesRoutes {
    
    func displayCountry(responseDisplay: CountriesAndStatesModels.SelectCountry.ResponseDisplay) {
        coordinator?.showCountrySelector(countries: responseDisplay.countries) { [weak self] model in
            self?.interactor?.pickCountry(viewAction: .init(code: model?.iso2, countryFullName: model?.name))
        }
    }
}
