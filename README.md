# Integration

## Source structure

The sources contain two folders:
- OpenCmp: The library itself, that has to be imported into the consuming project
- Example: Integration demo

## Integration

The integration can be done in the class AppDelegate:
```
let config = OpenCmpConfig(
    "domain.de",
    setErrorHandler: { result in
        print("Error", result)
    }, setChangesListener: { change in
        print("CMP change", change.value)
    })
//initialize framework
OpenCmp.initialize(config)
```

Change the identifier-path in OpenCmpSettings.swift where the CMP is located in your project:
```
import Foundation

struct CMPStaticList {
    static let identifier = "org.cocoapods.CMP"
    static let forResource = "cmp"
    static let cmpSettings = "cmpSettings"
    static let ofType = "html"
    static let domain = "$domain"
}
```
## Features
### Button for changing consent settings

To enable the user to change consent settings the CMP provides a function to show the UI:

```
OpenCmp.showUI()
```

### How to access the consent

The consent is stored in `UserDefaults.standard` and can be read from there and listened to changes. 

Please read the IAB specs for the specific names of the key value pairs that are stored:
https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#how-is-a-cmp-used-in-app 
