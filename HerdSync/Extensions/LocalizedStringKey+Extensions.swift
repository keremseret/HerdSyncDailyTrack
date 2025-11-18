import SwiftUI
import Foundation

func LocalizedString(_ key: String, comment: String = "") -> String {
    let language = LanguageService.shared.currentLanguage.rawValue
    if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
       let bundle = Bundle(path: path) {
        let localized = bundle.localizedString(forKey: key, value: nil, table: nil)
        if localized != key {
            return localized
        }
    }
    if let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
       let bundle = Bundle(path: path) {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
    return NSLocalizedString(key, comment: comment)
}

extension String {
    var localized: String {
        return LocalizedString(self)
    }
}

