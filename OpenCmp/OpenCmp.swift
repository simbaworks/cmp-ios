import UIKit

@available(iOS 9.0, *)
public class OpenCmp {
    
    public static func initialize(_ context: OpenCmpConfig) {
        if  let filePath = Bundle(identifier: CMPStaticList.identifier)?.path(forResource: CMPStaticList.forResource, ofType: CMPStaticList.ofType) {
            do {
                let jsContent = try String.init(contentsOfFile: filePath, encoding: String.Encoding.utf8)
                let web = WebPrezenterShared.shared
                web.cmpSettings = context
                web.cmpSettings.domain = jsContent.replacingOccurrences(of: CMPStaticList.domain, with: context.domain)
                web.userDefaultSettings = UserDefaultsOpenCmpStore(userDefaultsType: context.storageName ?? "", cmpSettings: context)
                web.view.backgroundColor = .clear
                web.modalTransitionStyle = .crossDissolve
                web.modalPresentationStyle = .fullScreen
                web.webView.loadHTMLString(web.cmpSettings.domain, baseURL: nil)
                
            }  catch let error as NSError{
                let err: Error = CmpError.loadingHtml(errorDescription: error.debugDescription)
                context.errorHandler?(CmpErrorReader.shared.handleError(err))
                
            }
        }
    }
    
    public static func showUI() {
        WebPrezenterShared.shared.triggerShowUi()
    }
    
    public static func clearData() {
        WebPrezenterShared.shared.clean()
    }
}

@available(iOS 9.0, *)
class WebPrezenterShared {
    static let shared = WebPrezenterViewController()
    private init() {}
}


