// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import Foundation

protocol FEError: Error {
    var errorMessage: String { get }
    var errorType: ServerResponse.ErrorType? { get }
}

struct GeneralError: FEError {
    var errorMessage: String = L10n.ErrorMessages.unknownError
    var errorType: ServerResponse.ErrorType?
}

enum NetworkingError: FEError, Equatable {
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
    case biometricAuthenticationRequired
    case biometricAuthenticationFailed
    case twoStepEmailRequired
    case twoStepAppRequired
    case twoStepInvalid
    case twoStepInvalidCode(Int?)
    case twoStepBlockedAccount
    case twoStepInvalidCodeBlockedAccount
    case inappropriatePaymail
    
    var errorMessage: String {
        switch self {
        case .general:
            return L10n.ErrorMessages.networkIssues
            
        case .noConnection:
            return L10n.ErrorMessages.checkInternet
            
        case .serverAtCapacity, .accessDenied:
            return L10n.ErrorMessages.somethingWentWrong
            
        case .twoStepInvalidCode(let attemptCount):
            return L10n.TwoStep.Error.attempts
            
        case .inappropriatePaymail:
            return L10n.PaymailAddress.inappropriateWordsMessage
            
        default:
            return L10n.ErrorMessages.unknownError
        }
    }
    
    var errorCategory: ServerResponse.ErrorCategory? {
        switch self {
        case .twoStepEmailRequired, .twoStepAppRequired, .twoStepInvalidCode,
                .twoStepBlockedAccount, .twoStepInvalidCodeBlockedAccount, .twoStepInvalid:
            return .twoStep
            
        default:
            return nil
        }
    }
    
    var errorType: ServerResponse.ErrorType? {
        switch self {
        case .exchangesUnavailable:
            return .exchangesUnavailable
            
        case .biometricAuthenticationFailed, .biometricAuthenticationRequired:
            return .biometricAuthentication
            
        case .twoStepAppRequired, .twoStepEmailRequired:
            return .twoStepRequired
            
        case .twoStepBlockedAccount:
            return .twoStepBlockedAccount
            
        case .twoStepInvalidCodeBlockedAccount:
            return .twoStepInvalidCodeBlockedAccount
            
        case .twoStepInvalidCode:
            return .twoStepInvalidCode
            
        case .twoStepInvalid:
            return .twoStepInvalid
            
        default:
            return nil
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
        
        case 400:
            if error?.serverMessage == ServerResponse.ErrorType.inappropriatePaymail.rawValue {
                self = .inappropriatePaymail
            } else {
                self = .general
            }
            
        case 401:
            switch TwoStepSettingsResponseData.TwoStepType(rawValue: error?.serverMessage ?? "") {
            case .authenticator:
                self = .twoStepAppRequired
                
            case .email:
                self = .twoStepEmailRequired
            
            default:
                if error?.serverMessage == ServerResponse.ErrorType.twoStepInvalidCode.rawValue {
                    self = .twoStepInvalidCode(error?.attemptsLeft)
                } else {
                    self = .accessDenied
                }
            }
            
        case 403:
            if error?.serverMessage == ServerResponse.ErrorType.twoStepBlockedAccount.rawValue {
                self = .twoStepBlockedAccount
            } else if error?.serverMessage == ServerResponse.ErrorType.twoStepInvalidCodeBlockedAccount.rawValue {
                self = .twoStepInvalidCodeBlockedAccount
            } else {
                self = .sessionNotVerified
            }
            
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
            
        case 1001:
            self = .biometricAuthenticationRequired
            
        case 1002:
            self = .biometricAuthenticationFailed
            
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
        let errorType = ServerResponse.ErrorType(rawValue: serverResponse?.errorType ?? "")
        var error = serverResponse?.error
        error?.errorType = errorType
        
        guard let error = NetworkingError(error: error) else { return error }
        
        return error
    }
}
