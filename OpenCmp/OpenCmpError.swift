
import Foundation

enum CmpError {
    case uiError(type: Enums.NetworkError)
    case loadingHtml(errorDescription: String?)

    class Enums { }
}

extension CmpError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .uiError(type): return type.localizedDescription
        case let .loadingHtml(errorDescription): return errorDescription
        }
    }
}

extension CmpError.Enums {
    enum NetworkError {
        case showUiError
        case hideUiError
        case cmpLoadingError(errorDescription: String?)
    }
}

extension CmpError.Enums.NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .showUiError: return "showUiError"
        case .hideUiError: return "hideUiError"
        case let .cmpLoadingError(errorDescription): return errorDescription
        }
    }
}

class CmpErrorReader {
    static let shared = CmpErrorReader()
    private init() {}

    func handleError(_ err: Error) -> String {
        switch err {
        case is CmpError:
            switch err as! CmpError {
            case let .loadingHtml(type):
               return  "CMP loadingHtml ERROR, \(type)"
            case let .uiError(type):
                return "uiError, \(type)"
            }
        default: return "CMP error"
        }
    }
}
