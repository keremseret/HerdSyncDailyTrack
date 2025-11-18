import SwiftUI
import CoreData
import Combine

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var languageService = LanguageService.shared
    @ObservedObject var themeService = ThemeService.shared
    @State private var showingResetConfirmation = false
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedString("settings.language"))) {
                    Picker(selection: Binding(
                        get: { languageService.currentLanguage },
                        set: { newLanguage in
                            languageService.setLanguage(newLanguage)
                            refreshID = UUID()
                        }
                    ), label: Text(LocalizedString("settings.language"))) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                }
                
                Section(header: Text(LocalizedString("settings.theme"))) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Button(action: {
                            themeService.setTheme(theme)
                        }) {
                            HStack {
                                Text(theme.localizedName)
                                Spacer()
                                if themeService.currentTheme == theme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive, action: {
                        showingResetConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Text(LocalizedString("settings.reset"))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(LocalizedString("settings.title"))
            .id(refreshID)
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                refreshID = UUID()
            }
            .alert(LocalizedString("settings.reset"), isPresented: $showingResetConfirmation) {
                Button(LocalizedString("settings.reset.cancel"), role: .cancel) {}
                Button(LocalizedString("settings.reset.confirmButton"), role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text(LocalizedString("settings.reset.confirm"))
            }
        }
    }
    
    private func resetAllData() {
        let herdRequest: NSFetchRequest<Herd> = Herd.fetchRequest()
        let goalRequest: NSFetchRequest<DailyGoal> = DailyGoal.fetchRequest()
        let recordRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        
        if let herds = try? viewContext.fetch(herdRequest) {
            herds.forEach { viewContext.delete($0) }
        }
        
        if let goals = try? viewContext.fetch(goalRequest) {
            goals.forEach { viewContext.delete($0) }
        }
        
        if let records = try? viewContext.fetch(recordRequest) {
            records.forEach { viewContext.delete($0) }
        }
        
        try? viewContext.save()
        
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }
}

extension AppTheme {
    var localizedName: String {
        switch self {
        case .system:
            return LocalizedString("settings.theme.system")
        case .light:
            return LocalizedString("settings.theme.light")
        case .dark:
            return LocalizedString("settings.theme.dark")
        }
    }
}

