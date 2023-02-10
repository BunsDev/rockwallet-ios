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
    func pickState(viewAction: CountriesAndStatesModels.SelectState.ViewAction)
}

protocol CountriesAndStatesActionResponses: FetchActionResponses {
    func presentCountry(actionResponse: CountriesAndStatesModels.SelectCountry.ActionResponse)
    func presentState(actionResponse: CountriesAndStatesModels.SelectState.ActionResponse)
}

protocol CountriesAndStatesResponseDisplays: FetchResponseDisplays {
    func displayCountry(responseDisplay: CountriesAndStatesModels.SelectCountry.ResponseDisplay)
    func displayState(responseDisplay: CountriesAndStatesModels.SelectState.ResponseDisplay)
}

protocol CountriesAndStatesDataStore: FetchDataStore {
    var country: String? { get set }
    var countryFullName: String? { get set }
    var countries: [Country] { get set }
    var states: [USState] { get set }
    var state: String? { get set }
    var stateCode: String? { get set }
}

protocol CountriesAndStatesRoutes {
    func showCountrySelector(countries: [Country], selected: ((Country?) -> Void)?)
    func showStateSelector(states: [USState], selected: ((USState?) -> Void)?)
}

extension Interactor where Self: CountriesAndStatesViewActions,
                           Self.DataStore: CountriesAndStatesDataStore,
                           Self.ActionResponses: CountriesAndStatesActionResponses {
    
    func pickCountry(viewAction: CountriesAndStatesModels.SelectCountry.ViewAction) {
        guard viewAction.iso2 == nil else {
            dataStore?.country = viewAction.iso2
            dataStore?.countryFullName = viewAction.countryFullName
            presenter?.presentData(actionResponse: .init(item: dataStore))
            
            return
        }
        
        CountriesWorker().execute(requestData: CountriesRequestData()) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.countries = data ?? []
                self?.presenter?.presentCountry(actionResponse: .init(countries: data))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func pickState(viewAction: CountriesAndStatesModels.SelectState.ViewAction) {
        guard viewAction.code == nil else {
            dataStore?.state = viewAction.state
            dataStore?.stateCode = viewAction.code
            presenter?.presentData(actionResponse: .init(item: dataStore))
            
            return
        }
        
        let states = dataStore?.countries.first(where: { $0.code == C.countryUS })?.states
        presenter?.presentState(actionResponse: .init(states: states))
    }
}

extension Presenter where Self: CountriesAndStatesActionResponses,
                           Self.ResponseDisplays: CountriesAndStatesResponseDisplays {
    
    func presentCountry(actionResponse: CountriesAndStatesModels.SelectCountry.ActionResponse) {
        guard let countries = actionResponse.countries else { return }
        viewController?.displayCountry(responseDisplay: .init(countries: countries))
    }
    
    func presentState(actionResponse: CountriesAndStatesModels.SelectState.ActionResponse) {
        guard let states = actionResponse.states else { return }
        viewController?.displayState(responseDisplay: .init(states: states))
    }
}

extension Controller where Self: CountriesAndStatesResponseDisplays,
                           Self.ViewActions: CountriesAndStatesViewActions,
                           Self.Coordinator: CountriesAndStatesRoutes {
    
    func displayCountry(responseDisplay: CountriesAndStatesModels.SelectCountry.ResponseDisplay) {
        coordinator?.showCountrySelector(countries: responseDisplay.countries) { [weak self] model in
            self?.interactor?.pickCountry(viewAction: .init(iso2: model?.iso2, countryFullName: model?.name))
        }
    }
    
    func displayState(responseDisplay: CountriesAndStatesModels.SelectState.ResponseDisplay) {
        coordinator?.showStateSelector(states: responseDisplay.states) { [weak self] model in
            self?.interactor?.pickState(viewAction: .init(code: model?.iso2, state: model?.name))
        }
    }
}
