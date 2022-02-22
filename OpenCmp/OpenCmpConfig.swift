import Foundation


public struct OpenCmpConfig {
    
    var domain: String
    let storageName: String?
    var errorHandler: ((String) -> (Void))? = nil
    var consentChangesListener: ((UserDefaultsOpenCmpStore) -> (Void))? = nil
    
    public init(_ domain: String, storageName: String? = nil, setErrorHandler: ((String)->(Void))? = nil, setChangesListener: ((UserDefaultsOpenCmpStore)->(Void))? = nil) {
        
        self.domain = domain
        self.storageName = storageName
        
        if setErrorHandler != nil {
            self.errorHandler =  { result in
                setErrorHandler?(result)
            }
        }
        
        if setChangesListener != nil {
            self.consentChangesListener = { result in
                setChangesListener?(result)
            }
        }
    }
    
}


