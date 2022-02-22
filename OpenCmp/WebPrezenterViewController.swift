import UIKit
import WebKit

protocol CMProtocol: class {
    func getConsent(promiseId: String)
    func setConsent(info: [String: Any])
    func triggerShowUi()
    func hideUi()
}

//MARK: - main class

@available(iOS 9.0, *)
final class WebPrezenterViewController: UIViewController {
    
    //MARK: properties
    
    private enum WebViewKeyPath: String {
        case estimatedProgress
    }

    private enum CMProtocolEnum: String {
        case getConsent
        case setConsent
        case showUi
        case hideUi
    }

    private let topMargin: CGFloat = 10.0
    private var lastLocation: CGPoint = .zero
    private lazy var container = UIView(frame: CGRect.zero)
    private lazy var progressView = UIProgressView(progressViewStyle: .bar)
    private(set) var webView: WKWebView!
    
    var cmpSettings: OpenCmpConfig!
    var userDefaultSettings: OpenCmpStore!

    private var config: WKWebViewConfiguration {
        let contentController = WKUserContentController()
        contentController.add(
            self,
            name: CMProtocolEnum.getConsent.rawValue
        )
        contentController.add(
            self,
            name: CMProtocolEnum.setConsent.rawValue
        )
        contentController.add(
            self,
            name: CMProtocolEnum.showUi.rawValue
        )
        contentController.add(
            self,
            name: CMProtocolEnum.hideUi.rawValue
        )

        let config = WKWebViewConfiguration()
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        config.preferences = prefs
        config.userContentController = contentController
        return config
    }

    private lazy var toolbar: UIView = {
        let v = UIView(frame: CGRect.zero)
        v.isUserInteractionEnabled = true
        v.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

        v.translatesAutoresizingMaskIntoConstraints = false

        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        v.addSubview(blurEffectView)
        blurEffectView.bindFrameToSuperviewBounds()
        return v
    }()

    private lazy var urlLabel: UILabel = {
        let lbl = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 250.0, height: 10.0))
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.9
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 10)
        return lbl
    }()
    
    //MARK: functions

    override public func loadView() {
        super.loadView()
        
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        
        setupMainLayout()
        setupToolbar()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        webView.navigationDelegate = self
        
        addWebViewObservers()
        
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeWebViewObservers()
    }

    

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case WebViewKeyPath.estimatedProgress.rawValue:
            progressView.progress = Float(webView.estimatedProgress)
            if progressView.progress == 1.0 {
                progressView.alpha = 0.0
            } else if progressView.alpha != 1.0 {
                progressView.alpha = 1.0
            }

        default:
            break
        }
    }
}

//MARK: - private section

@available(iOS 9.0, *)
private extension WebPrezenterViewController {
    func setupToolbar() {
        let titleStackView = UIStackView(arrangedSubviews: [urlLabel])
        titleStackView.axis = .vertical
        
        let toolbarStackView = UIStackView(arrangedSubviews: [titleStackView])
        toolbarStackView.spacing = 2.0
        toolbarStackView.axis = .horizontal
        toolbar.addSubview(toolbarStackView)
        
        toolbarStackView.translatesAutoresizingMaskIntoConstraints = false
        toolbarStackView.topAnchor.constraint(equalTo: toolbar.topAnchor, constant: 5).isActive = true
        toolbarStackView.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 5).isActive = true
        toolbarStackView.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: -5).isActive = true
        toolbarStackView.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -49).isActive = true
    }
    
    func setupMainLayout() {
        view = UIView()
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.backgroundColor = .clear
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(
            equalTo: view.safeTopAnchor, constant: topMargin).isActive = true
        container.bottomAnchor.constraint(
            equalTo: view.bottomAnchor).isActive = true
        container.leadingAnchor.constraint(
            equalTo: view.safeLeadingAnchor, constant: 0).isActive = true
        container.trailingAnchor.constraint(
            equalTo: view.safeTrailingtAnchor, constant: 0).isActive = true
        container.layer.cornerRadius = 16.0
        container.clipsToBounds = true
        
        let progressViewContainer = UIView()
        progressViewContainer.addSubview(progressView)
        progressView.bindFrameToSuperviewBounds()
        progressViewContainer.heightAnchor.constraint(equalToConstant: 1)
            .isActive = true
        
        let mainStackView = UIStackView(arrangedSubviews: [
                                            toolbar,
                                            progressViewContainer,
                                            webView])
        
        mainStackView.axis = .vertical
        container.addSubview(mainStackView)
        mainStackView.bindFrameToSuperviewBounds()
    }
    
    func addWebViewObservers() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
    }
    
    func removeWebViewObservers() {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
    }
    
    func showUi() {
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self, !(UIApplication.topViewController() is WebPrezenterViewController) {
                UIApplication.topViewController()?.present(strongSelf, animated: true, completion: nil)
            }
        }
    }
}

//MARK: - WKScriptMessageHandler

@available(iOS 9.0, *)
extension WebPrezenterViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let cmpEnum = CMProtocolEnum(rawValue: message.name) {
            switch cmpEnum {
            case .getConsent:
                let promiseId = message.body as? String ?? ""
                getConsent(promiseId: promiseId)
            case .setConsent:
                if let result = convertStringToDictionary(text: message.body as? String ?? "") {
                    setConsent(info: result)
                }
            case .showUi:
                showUi()
            case .hideUi:
                hideUi()
            }
        } else {
            print("There isn't a CMP procol")
        }
    }
}

//MARK: - WKNavigationDelegate

@available(iOS 9.0, *)
extension WebPrezenterViewController: WKNavigationDelegate {
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            webView.load(navigationAction.request)
        default:
            break
        }
        decisionHandler(.allow)
    }
}

//MARK: - public section

@available(iOS 9.0, *)
extension WebPrezenterViewController {
    
    final func clean() {
        self.userDefaultSettings.clear()
        WKWebView.clean()
    }

    final func convertStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                return json
            } catch {
                print("error JSONSerialization")
            }
        }
        return nil
    }
}

//MARK: - CMProtocol

@available(iOS 9.0, *)
extension WebPrezenterViewController: CMProtocol {
    final func getConsent(promiseId: String) {
        do {
            let consent = try userDefaultSettings.getConsentString()
            // Send update to the page
            webView.evaluateJavaScript("trfCmpResolvePromise('\(promiseId)', \(consent))") { _, error in
                if let jsError = error {
                    print(jsError)
                    return
                }
            }
        } catch (let error) {
            let err: Error = CmpError.uiError(type: .cmpLoadingError(errorDescription: error.localizedDescription))
            self.cmpSettings.errorHandler?(CmpErrorReader.shared.handleError(err))
            
        }
    }

    final func setConsent(info: [String: Any]) {
        userDefaultSettings.update(values: info)
    }

    final func triggerShowUi() {
        webView.evaluateJavaScript("__tcfapi(\"showUi\", 2, function(){})") { _, error in
            if let jsError = error {
                print(jsError)
                return
            }
        }
    }

    final func hideUi() {
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.dismiss(animated: true, completion: nil)
            } else {
                let err: Error = CmpError.uiError(type: .hideUiError)
                self?.cmpSettings.errorHandler?(CmpErrorReader.shared.handleError(err))
            }
        }
    }
}
