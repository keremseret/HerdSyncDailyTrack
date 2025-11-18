import SwiftUI
import CoreData

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: StatisticsViewModel
    @ObservedObject var languageService = LanguageService.shared
    
    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(viewContext: viewContext))
    }
    
    var body: some View {
        let appLocale = Locale(identifier: languageService.currentLanguage.rawValue)
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = appLocale
        
        return NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    DatePicker(
                        LocalizedString("statistics.selectDate"),
                        selection: $viewModel.selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .environment(\.locale, appLocale)
                    .environment(\.calendar, calendar)
                    .id("\(languageService.currentLanguage.rawValue)-calendar")
                    .padding()
                    .onChange(of: viewModel.selectedDate) { newValue in
                        viewModel.updateSelectedDate(newValue)
                    }
                    
                    VStack(spacing: 12) {
                        Text(LocalizedString("statistics.completionRate"))
                            .font(.headline)
                        Text("\(Int(viewModel.completionRate))%")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(viewModel.completionRate >= 80 ? .green : viewModel.completionRate >= 50 ? .orange : .red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    if viewModel.hasHerds {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.records, id: \.id) { record in
                                if let date = record.date {
                                    StatisticsRow(record: record, date: date)
                                        .id("\(record.id?.uuidString ?? "")-\(record.isCompleted)-\(record.milk)-\(record.eggs)-\(record.wool)")
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(LocalizedString("statistics.title"))
            .environment(\.locale, appLocale)
            .environment(\.calendar, calendar)
            .task {
                viewModel.loadStatistics()
            }
            .onAppear {
                viewModel.loadStatistics()
            }
        }
        .environment(\.locale, appLocale)
        .environment(\.calendar, calendar)
    }
}

struct StatisticsRow: View {
    @ObservedObject var record: DailyRecord
    let date: Date
    @ObservedObject var languageService = LanguageService.shared
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: languageService.currentLanguage.rawValue)
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateFormatter.string(from: date))
                    .font(.headline)
                Spacer()
                if record.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                Label("\(formatValue(record.milk)) \(ProductType.milk.unit)", systemImage: "drop.fill")
                Spacer()
                Label("\(record.eggs) \(ProductType.eggs.unit)", systemImage: "oval.fill")
                Spacer()
                Label("\(formatValue(record.wool)) \(ProductType.wool.unit)", systemImage: "scissors")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

