import Foundation
import UIKit

protocol OpenCmpStore {
    func clear()
    func update(values: [String: Any]?)
    func getConsentString() throws -> String
}

public class UserDefaultsOpenCmpStore: OpenCmpStore {
    private let userDefaultsName: String?
    private let userDefaults: UserDefaults?
    private var observer: NSKeyValueObservation?
    public var value: [String: Any] = [:]

    required init(userDefaultsType: String, cmpSettings: OpenCmpConfig) {
        userDefaultsName = userDefaultsType
        userDefaults = userDefaultsType == "" ? UserDefaults.standard : UserDefaults(suiteName: userDefaultsName)!

        observer = userDefaults?.observe(\.cmpSettings, options: [.old, .new], changeHandler: { [self] _, change in
            
            guard let new = change.newValue else {
                value.removeAll()
                cmpSettings.consentChangesListener?(self)
                return
            }

            guard let old = change.oldValue else { return }

            guard let dict = NSKeyedUnarchiver.unarchiveObject(with: new) as? [String: Any], let dictOld = NSKeyedUnarchiver.unarchiveObject(with: old) as? [String: Any] else { return }
            value.removeAll()
            for (key, item) in dict {
                if let settings = item as? [String: Any] {
                    for (keySettings, settingsItem) in settings {
                        if let dictSettingsOld = dictOld[key] as? [String: Any] {
                            checkValueInOldValue(dictSettingsOld, key: keySettings, item: settingsItem)
                        }
                    }
                } else {
                    checkValueInOldValue(dictOld, key: key, item: item)
                }
            }
            cmpSettings.consentChangesListener?(self)
        })
    }

    final func checkValueInOldValue(_ dict: [String: Any], key: String, item: Any) {
        if let currentValue = dict[key] {
            if !compare(a: currentValue, b: item) {
                value[key] = item
            }
        } else {
            value[key] = item
        }
    }

    func compare(a: Any, b: Any) -> Bool {
        if let va = a as? Int, let vb = b as? Int {
            if va != vb { return false }
        } else if let va = a as? String, let vb = b as? String { if va != vb { return false }
        } else if let va = a as? Bool, let vb = b as? Bool { if va != vb { return false }
        }
        return true
    }

    deinit {
        observer?.invalidate()
    }

    final func clear() {
        userDefaults?.removeObject(forKey: CMPStaticList.cmpSettings)
    }

    final func update(values: [String: Any]?) {
        guard let archivedData = values else { return }
        let convertData = NSKeyedArchiver.archivedData(withRootObject: archivedData)
        userDefaults?.set(convertData, forKey: CMPStaticList.cmpSettings)
    }

    final func getConsentString() throws -> String {
        let data = userDefaults?.object(forKey: CMPStaticList.cmpSettings)
        
        let emptyDict: [String : Any?] = ["meta" : [:]]
        let jsonEmptyData = try JSONSerialization.data(withJSONObject: emptyDict, options: [])
        let jsonEmptyString = String(data: jsonEmptyData, encoding: String.Encoding.utf8) ?? ""
        
        guard let convert = data as? Data else { return jsonEmptyString }//"{\"meta\":{}}" }
        
        let dict = NSKeyedUnarchiver.unarchiveObject(with: convert)
        let jsonData = try JSONSerialization.data(withJSONObject: dict ?? [], options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
        if !jsonString.isEmpty {
            return jsonString
        } else {
            
            return jsonEmptyString
        }
    }
}

private extension UserDefaults {
    @objc dynamic var cmpSettings: Data {
        return data(forKey: CMPStaticList.cmpSettings)!
    }
}
