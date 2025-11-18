import Foundation
import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

class ThemeService: ObservableObject {
    static let shared = ThemeService()
    
    @Published var currentTheme: AppTheme = .system
    private let themeKey = "selected_theme"
    
    private init() {
        loadTheme()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
    }
    
    private func loadTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
}

