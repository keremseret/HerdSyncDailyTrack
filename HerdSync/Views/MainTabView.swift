import SwiftUI
import CoreData
import Combine

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var languageService = LanguageService.shared
    @State private var refreshID = UUID()
    
    var body: some View {
        TabView {
            PlanView(viewContext: viewContext)
                .tabItem {
                    Label(LocalizedString("tab.plan"), systemImage: "calendar")
                }
            
            GoalsView(viewContext: viewContext)
                .tabItem {
                    Label(LocalizedString("tab.goals"), systemImage: "target")
                }
            
            HerdView(viewContext: viewContext)
                .tabItem {
                    Label(LocalizedString("tab.herd"), systemImage: "pawprint.fill")
                }
            
            StatisticsView(viewContext: viewContext)
                .tabItem {
                    Label(LocalizedString("tab.statistics"), systemImage: "chart.bar")
                }
            
            SettingsView()
                .tabItem {
                    Label(LocalizedString("tab.settings"), systemImage: "gearshape")
                }
        }
        .id(refreshID)
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            refreshID = UUID()
        }
        .onAppear {
            setPortraitOrientation()
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

