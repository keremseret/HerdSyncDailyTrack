import SwiftUI

struct LanguageSelectionView: View {
    @ObservedObject var languageService = LanguageService.shared
    @State private var selectedLanguage: Language?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedString("language.select"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            if let deviceLanguage = languageService.getDeviceLanguage() {
                VStack(spacing: 12) {
                    Text(LocalizedString("language.recommended"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        selectedLanguage = deviceLanguage
                        languageService.setLanguage(deviceLanguage)
                    }) {
                        HStack {
                            Text(deviceLanguage.displayName)
                                .font(.title2)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
            }
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Language.allCases, id: \.self) { language in
                        if language != languageService.getDeviceLanguage() {
                            Button(action: {
                                selectedLanguage = language
                                languageService.setLanguage(language)
                            }) {
                                HStack {
                                    Text(language.displayName)
                                        .font(.title3)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

