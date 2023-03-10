// 
//  PaymentPath.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2020-04-28.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

// REMOVE

import Foundation
import Cosmos

enum ResolvableError: Error {
    case invalidPayID
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
    case payId
    case fio
    case uDomains
    case ens
    
    var label: String {
        switch self {
        case .payId:
            return "PayString"
        case .fio:
            return "FIO"
        case .uDomains:
            return "Unstoppable"
        case .ens:
            return "ENS"
        }
    }
    
    var iconName: String {
        switch self {
        case .payId:
            return "payidIcon"
        case .fio:
            return "fioIcon"
        case .uDomains:
            return "udomainIcon"
        case .ens:
            return "ensIcon"
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
        
        if let payId = PayId(address: address) {
            return payId
        }
        
        if let cns = UDomains(address: address) {
            return cns
        }
        
        if let ens = ENS(address: address) {
            return ens
        }
        
        return nil
    }
}

private class Fio: Resolvable {
    
    private let address: String
    
    let type: ResolvableType = .fio
    
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

private class PayId: Resolvable {
    
    let type: ResolvableType = .payId
    
    private let separator = "$"
    private let address: String
    
    required init?(address: String) {
        self.address = address
        guard isValidAddress(address) else { return nil }
    }
    
    // response: (String, String?) == (cryptoAddress, destinationTag(optional) )
    func fetchAddress(forCurrency currency: Currency, callback: @escaping (Result<(String, String?), ResolvableError>) -> Void) {
        guard currency.payId != nil else { callback(.failure(.currencyNotSupported)); return }
        let components = address.components(separatedBy: separator)
        guard components.count == 2, !components[0].isEmpty, !components[1].isEmpty else {
            callback(.failure(.invalidPayID)); return
        }
        
        let name = components[0]
        let domain = components[1]
        guard let url = URL(string: "https://\(domain)/\(name)") else { callback(.failure(.invalidPayID)); return }
        var request = URLRequest(url: url)
        request.addValue("application/payid+json", forHTTPHeaderField: "Accept")
        request.addValue("1.0", forHTTPHeaderField: "PayID-Version")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { callback(.failure(.badResponse)); return }
            guard let response = try? JSONDecoder().decode(PayIdResponse.self, from: data) else {
                callback(.failure(.badResponse)); return }
            guard let first = response.addresses.first(where: { currency.doesMatchPayId($0) }) else { callback(.failure(.currencyNotSupported)); return }
            callback(.success((first.addressDetails.address, first.addressDetails.tag)))
        }.resume()
    }
    
    private func isValidAddress(_ address: String) -> Bool {
        let pattern = ".+\\$.+"
        let range = address.range(of: pattern, options: .regularExpression)
        return range != nil
    }
}

struct PayIdResponse: Codable {
    let payId: String?
    let addresses: [PayIdAddress]
}

struct PayIdAddress: Codable {
    let paymentNetwork: String
    let environment: String
    let addressDetailsType: String
    let addressDetails: PayIdAddressDetails
}

struct PayIdAddressDetails: Codable {
    let address: String
    let tag: String?
}

private class UDomains: Resolvable {
    private let address: String
    let type: ResolvableType = .uDomains
    required init?(address: String) {
        self.address = address
        guard address.hasSuffix(".crypto") else { return nil }
    }
    
    func fetchAddress(forCurrency currency: Currency, callback: @escaping (Result<(String, String?), ResolvableError>) -> Void) {
        Backend.bdbClient.addressLookup(domainName: address, currencyCodeList: [currency.code]) { (result, _) in
            guard result != nil,
                  let success = result as? BdbAddresses else {
                callback(.failure(.badResponse))
                return
            }
            let value = success.embedded.addresses.first
            if value?.status == BdbAddress.Status.success {
                callback(.success((value!.address!, nil)))
            } else {
                callback(.failure(.badResponse))
            }
        }
    }
}

private class ENS: Resolvable {
    private let address: String
    let type: ResolvableType = .ens
    required init?(address: String) {
        self.address = address
        guard address.hasSuffix(".eth") else { return nil }
    }
    
    func fetchAddress(forCurrency currency: Currency, callback: @escaping (Result<(String, String?), ResolvableError>) -> Void) {
        Backend.bdbClient.addressLookup(domainName: address, currencyCodeList: [currency.code]) { (result, _) in
            guard result != nil,
                  let success = result as? BdbAddresses else {
                callback(.failure(.badResponse))
                return
            }
            let value = success.embedded.addresses.first
            if value?.status == BdbAddress.Status.success {
                callback(.success((value!.address!, nil)))
            } else {
                callback(.failure(.badResponse))
            }
        }
    }
}
