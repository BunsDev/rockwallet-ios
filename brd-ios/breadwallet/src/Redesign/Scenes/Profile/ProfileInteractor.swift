//
//  ProfileInteractor.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

class ProfileInteractor: NSObject, Interactor, ProfileViewActions {
    
    typealias Models = ProfileModels

    var presenter: ProfilePresenter?
    var dataStore: ProfileStore?

    // MARK: - ProfileViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        UserManager.shared.refresh { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentData(actionResponse: .init(item: Models.Item()))
                
                guard UserManager.shared.profile?.status.hasKYCLevelTwo ?? false else { return }
                self?.fetchCards()
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
                
            default:
                return
            }
        }
    }
    
    func logout(viewAction: ProfileModels.Logout.ViewAction) {
        LogoutWorker().execute { [weak self] result in
            switch result {
            case .success:
                UserManager.shared.resetUserCredentials()
                self?.presenter?.presentLogout(actionResponse: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func showVerificationInfo(viewAction: ProfileModels.VerificationInfo.ViewAction) {
        presenter?.presentVerificationInfo(actionResponse: .init(verified: UserManager.shared.profile?.status.hasKYCLevelTwo ?? false))
    }
    
    func navigate(viewAction: ProfileModels.Navigate.ViewAction) {
        presenter?.presentNavigation(actionResponse: .init(index: viewAction.index))
    }
    
    // MARK: - Additional helpers
    private func fetchCards() {
        PaymentCardsWorker().execute(requestData: PaymentCardsRequestData()) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.allPaymentCards = data
                self?.dataStore?.paymentCard = self?.dataStore?.allPaymentCards?.first
                
                let paymentCards = self?.dataStore?.allPaymentCards?.filter { $0.type == .card }
                self?.presenter?.presentPaymentCards(actionResponse: .init(allPaymentCards: paymentCards ?? []))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
}
