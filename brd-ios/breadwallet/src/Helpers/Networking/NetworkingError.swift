// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import Foundation

protocol FEError: Error {
    var errorMessage: String { get }
    var errorType: ServerResponse.ErrorType { get }
}

struct GeneralError: FEError {
    var errorMessage: String = L10n.ErrorMessages.unknownError
    var errorType: ServerResponse.ErrorType = .empty
}

enum NetworkingError: FEError {
    case general
    case noConnection
    case accessDenied
    case parameterMissing
    case sessionExpired
    case sessionNotVerified
    case dataUnavailable
    case unprocessableEntity
    case serverAtCapacity
    case exchangesUnavailable
    
    var errorMessage: String {
        switch self {
        case .general:
            return L10n.ErrorMessages.networkIssues
            
        case .noConnection:
            return L10n.ErrorMessages.checkInternet
            
        case .accessDenied:
            return L10n.ErrorMessages.accessDenied
            
        case .serverAtCapacity:
            return L10n.ErrorMessages.somethingWentWrong
            
        default:
            return L10n.ErrorMessages.unknownError
        }
    }
    
    var errorType: ServerResponse.ErrorType {
        switch self {
        case .exchangesUnavailable:
            return .exchangesUnavailable
            
        default:
            return .empty
        }
    }
    
    init?(error: ServerResponse.ServerError?) {
        switch error?.statusCode {
        case 101:
            self = .accessDenied
            
        case 103:
            self = .parameterMissing
            
        case 105:
            self = .sessionExpired
            
        case 403:
            self = .sessionNotVerified
            
        case 404:
            self = .dataUnavailable
            
        case 422:
            self = .unprocessableEntity
            
        case 503:
            switch error?.errorType {
            case .exchangesUnavailable:
                self = .exchangesUnavailable
            
            default:
                self = .serverAtCapacity
            }
            
        default:
            return nil
        }
    }
}

public class NetworkingErrorManager {
    static func getError(from response: HTTPURLResponse?, data: Data?, error: Error?) -> FEError? {
        if data?.isEmpty == true && error == nil {
            return nil
        }
        
        if let error = error as? URLError, error.code == .notConnectedToInternet {
            return NetworkingError.noConnection
        }
        
        let serverResponse = ServerResponse.parse(from: data, type: ServerResponse.self)
        let errorType = ServerResponse.ErrorType(rawValue: serverResponse?.errorType ?? "") ?? .empty
        var error = serverResponse?.error
        error?.errorType = errorType
        
        guard let error = NetworkingError(error: error) else { return error }
        
        return error
    }
    
    static func getImageUploadEncodingError() -> FEError? {
        // TODO: Is this right?
        return GeneralError(errorMessage: "Image encoding failed.")
    }
}
