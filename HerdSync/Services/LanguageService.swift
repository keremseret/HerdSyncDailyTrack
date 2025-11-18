import Foundation
import SwiftUI
import Combine

class LanguageService: ObservableObject {
    static let shared = LanguageService()
    
    @Published var currentLanguage: Language = .english
    private let languageKey = "selected_language"
    private let hasSelectedLanguageKey = "has_selected_language"
    
    private init() {
        loadLanguage()
    }
    
    var hasSelectedLanguage: Bool {
        return UserDefaults.standard.bool(forKey: hasSelectedLanguageKey)
    }
    
    func setLanguage(_ language: Language) {
        let wasAlreadySelected = hasSelectedLanguage
        
        if currentLanguage != language {
            currentLanguage = language
            UserDefaults.standard.set(language.rawValue, forKey: languageKey)
        }
        
        if !wasAlreadySelected {
            UserDefaults.standard.set(true, forKey: hasSelectedLanguageKey)
        }
        
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
    
    private func loadLanguage() {
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        } else {
            if let deviceLanguage = getDeviceLanguage() {
                currentLanguage = deviceLanguage
            }
        }
    }
    
    func getDeviceLanguage() -> Language? {
        guard let preferredLanguage = Locale.preferredLanguages.first else {
            return .english
        }
        
        if let language = Language(rawValue: preferredLanguage) {
            return language
        }
        
        let languageCode = String(preferredLanguage.prefix(2))
        
        if languageCode == "zh" {
            if preferredLanguage.contains("Hans") || preferredLanguage.contains("CN") || preferredLanguage.contains("SG") {
                return .chineseSimplified
            } else {
                return .chineseTraditional
            }
        }
        
        if languageCode == "en" {
            if preferredLanguage.contains("AU") {
                return .englishAustralia
            } else if preferredLanguage.contains("CA") {
                return .englishCanada
            } else if preferredLanguage.contains("GB") {
                return .englishUK
            } else if preferredLanguage.contains("US") {
                return .englishUS
            } else {
                return .english
            }
        }
        
        if languageCode == "fr" {
            if preferredLanguage.contains("CA") {
                return .frenchCanada
            } else {
                return .french
            }
        }
        
        if languageCode == "pt" {
            if preferredLanguage.contains("BR") {
                return .portugueseBrazil
            } else if preferredLanguage.contains("PT") {
                return .portuguesePortugal
            }
        }
        
        if languageCode == "es" {
            if preferredLanguage.contains("MX") {
                return .spanishMexico
            } else {
                return .spanishSpain
            }
        }
        
        if let language = Language(rawValue: languageCode) {
            return language
        }
        
        if let language = Language(rawValue: preferredLanguage) {
            return language
        }
        
        return .english
    }
}

