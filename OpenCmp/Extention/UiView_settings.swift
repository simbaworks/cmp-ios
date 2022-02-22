import Foundation
import UIKit

@available(iOS 9.0, *)
extension UIView {
  
  var safeTopAnchor: NSLayoutYAxisAnchor {
    if #available(iOS 11.0, *) {
      return self.safeAreaLayoutGuide.topAnchor
    }
    return self.topAnchor
  }
  
  var safeLeadingAnchor: NSLayoutXAxisAnchor {
    if #available(iOS 11.0, *){
      return self.safeAreaLayoutGuide.leadingAnchor
    }
    return self.leadingAnchor
  }
  
  var safeTrailingtAnchor: NSLayoutXAxisAnchor {
    if #available(iOS 11.0, *){
      return self.safeAreaLayoutGuide.trailingAnchor
    }
    return self.trailingAnchor
  }
  
  var safeBottomAnchor: NSLayoutYAxisAnchor {
    if #available(iOS 11.0, *) {
      return self.safeAreaLayoutGuide.bottomAnchor
    }
    return self.bottomAnchor
  }
  
  func bindFrameToSuperviewBounds() {
    guard let superview = self.superview else {
      print("Error! `superview` was nil – call `addSubview(view: UIView)`")
      return
    }
    
    self.translatesAutoresizingMaskIntoConstraints = false
    self.topAnchor.constraint(
      equalTo: superview.topAnchor, constant: 0).isActive = true
    self.bottomAnchor.constraint(
      equalTo: superview.bottomAnchor, constant: 0).isActive = true
    self.leadingAnchor.constraint(
      equalTo: superview.leadingAnchor, constant: 0).isActive = true
    self.trailingAnchor.constraint(
      equalTo: superview.trailingAnchor, constant: 0).isActive = true
  }
}

extension UIApplication {
    
    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}
