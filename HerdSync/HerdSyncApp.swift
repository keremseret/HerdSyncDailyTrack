import SwiftUI
import CoreData
import Combine

@main
struct HerdSyncApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    @StateObject private var languageService = LanguageService.shared
    @StateObject private var themeService = ThemeService.shared
    @State private var showBrowser = false
    @State private var webLink: String = ""
    
    var body: some Scene {
        let appLocale = Locale(identifier: languageService.currentLanguage.rawValue)
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = appLocale
        
        return WindowGroup {
            RootView(
                showBrowser: $showBrowser,
                webLink: $webLink
            )
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(languageService)
            .environmentObject(themeService)
            .preferredColorScheme(themeService.currentTheme.colorScheme)
            .environment(\.locale, appLocale)
            .environment(\.calendar, calendar)
        }
    }
}

struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var languageService: LanguageService
    @EnvironmentObject var themeService: ThemeService
    @Binding var showBrowser: Bool
    @Binding var webLink: String
    @State private var refreshID = UUID()
    @State private var hasFetchedToken = false
    @State private var shouldShowLanguageSelection = false
    
    var body: some View {
        ZStack {
            if !hasFetchedToken {
                ProgressView()
                    .onAppear {
                        fetchTokenFirst()
                        setPortraitOrientation()
                    }
            } else if showBrowser {
                BrowserScreen(link: webLink)
                    .ignoresSafeArea(.all, edges: .all)
            } else if shouldShowLanguageSelection && !languageService.hasSelectedLanguage {
                LanguageSelectionView()
                    .onAppear {
                        setPortraitOrientation()
                    }
                    .onChange(of: languageService.hasSelectedLanguage) { hasSelected in
                        if hasSelected {
                            navigateAfterLanguageSelection()
                        }
                    }
            } else {
                MainTabView()
            }
        }
        .id(refreshID)
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            refreshID = UUID()
        }
        .onChange(of: languageService.currentLanguage) { _ in
            refreshID = UUID()
        }
        .onAppear {
            if !showBrowser {
                setPortraitOrientation()
            }
        }
        .onChange(of: showBrowser) { isShowing in
            if !isShowing {
                setPortraitOrientation()
            }
        }
        .onChange(of: hasFetchedToken) { fetched in
            if fetched && !showBrowser {
                setPortraitOrientation()
            }
        }
        .onChange(of: shouldShowLanguageSelection) { shouldShow in
            if shouldShow && !showBrowser {
                setPortraitOrientation()
            }
        }
    }
    
    private func fetchTokenFirst() {
        if let savedToken = TokenService.shared.getToken(),
           let savedLink = TokenService.shared.getLink(),
           !savedToken.isEmpty,
           !savedLink.isEmpty {
            DispatchQueue.main.async {
                webLink = savedLink
                showBrowser = true
                hasFetchedToken = true
            }
        } else {
            TokenService.shared.fetchToken { token, link in
                DispatchQueue.main.async {
                    if let token = token, let link = link, !token.isEmpty, !link.isEmpty {
                        TokenService.shared.saveToken(token)
                        TokenService.shared.saveLink(link)
                        webLink = link
                        showBrowser = true
                    } else {
                        shouldShowLanguageSelection = true
                    }
                    hasFetchedToken = true
                }
            }
        }
    }
    
    private func navigateAfterLanguageSelection() {
        if TokenService.shared.getToken() != nil,
           let savedLink = TokenService.shared.getLink() {
            webLink = savedLink
            showBrowser = true
        } else {
            showBrowser = false
        }
    }
    
    
    private func setPortraitOrientation() {
        AppDelegate.orientationLock = .portrait
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: AppDelegate.orientationLock))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

