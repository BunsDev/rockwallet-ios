//
//  SetPasswordPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import Cosmos

enum ResolvableError: Error {
    case invalidPaymail
    case badResponse
    case currencyNotSupported
    case invalidAddress
}

protocol Resolvable {
    init?(address: String)
    var type: ResolvableType { get }
    func fetchAddress(forCurrency currency: Currency, callback: @escaping (Result<(String, String?), ResolvableError>) -> Void)
}

enum ResolvableType {
    case paymail
    
    var label: String {
        switch self {
        case .paymail:
            return "Paymail"
        }
    }
    
    var iconName: String? {
        switch self {
        case .paymail:
            return "PaymailIcon"
        }
    }
}

struct ResolvedAddress {
    let humanReadableAddress: String
    let cryptoAddress: String
    let label: String
    let type: ResolvableType
}

enum ResolvableFactory {
    static func resolver(_ address: String) -> Resolvable? {
        if let fio = Fio(address: address) {
            return fio
        }
        
        return nil
    }
}

private class Fio: Resolvable {
    
    private let address: String
    
    let type: ResolvableType = .paymail
    
    required init?(address: String) {
        self.address = address
        guard isValidAddress(address) else { return nil }
    }
    
    func fetchAddress(forCurrency currency: Currency, callback: @escaping (Result<(String, String?), ResolvableError>) -> Void) {
        guard currency.isBitcoinSV else {
            callback(.failure(.currencyNotSupported))
            
            return
        }
        
        PaymailDestinationWorker().execute(requestData: PaymailDestinationRequestData(address: address)) { result in
            switch result {
            case .success(let data):
                callback(.success((data?.output ?? "", "")))
                
            case .failure(let error):
                callback(.failure(.currencyNotSupported))
            }
        }
    }
    
    private func isValidAddress(_ address: String) -> Bool {
        let pattern = ".+\\@.+"
        let range = address.range(of: pattern, options: .regularExpression)
        return range != nil
    }
    
    private struct FioResponse: Codable {
        let public_address: String
        
        func address() -> String {
            let components = public_address.components(separatedBy: "?dt=")
            if !components.isEmpty {
                return components[0]
            } else {
                return ""
            }
        }
        
        func tag() -> String? {
            let components = public_address.components(separatedBy: "?dt=")
            if components.count == 2 {
                return components[1]
            } else {
                return nil
            }
        }
    }
    
    private struct FioError: Codable {
        let message: String
    }
}
