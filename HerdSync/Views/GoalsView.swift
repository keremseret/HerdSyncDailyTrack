import SwiftUI
import CoreData

struct GoalsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: GoalsViewModel
    @FocusState private var focusedField: Field?
    @State private var milkGoalText: String = ""
    @State private var eggsGoalText: String = ""
    @State private var woolGoalText: String = ""
    
    enum Field {
        case milk, eggs, wool
    }
    
    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: GoalsViewModel(viewContext: viewContext))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedString("goals.milk"))
                            .font(.headline)
                        HStack {
                            TextField("", text: $milkGoalText)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .milk)
                            Text(ProductType.milk.unit)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedString("goals.eggs"))
                            .font(.headline)
                        HStack {
                            TextField("", text: $eggsGoalText)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .eggs)
                            Text(ProductType.eggs.unit)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedString("goals.wool"))
                            .font(.headline)
                        HStack {
                            TextField("", text: $woolGoalText)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .wool)
                            Text(ProductType.wool.unit)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        hideKeyboard()
                        saveGoals()
                    }) {
                        HStack {
                            Spacer()
                            Text(LocalizedString("goals.save"))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(LocalizedString("goals.title"))
            .onAppear {
                loadGoals()
            }
            .onChange(of: focusedField) { newValue in
                if newValue == .milk {
                    milkGoalText = ""
                } else if newValue == .eggs {
                    eggsGoalText = ""
                } else if newValue == .wool {
                    woolGoalText = ""
                }
            }
        }
    }
    
    private func loadGoals() {
        viewModel.loadTodayGoals()
        milkGoalText = formatValue(viewModel.milkGoal)
        eggsGoalText = formatValue(viewModel.eggsGoal)
        woolGoalText = formatValue(viewModel.woolGoal)
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    private func saveGoals() {
        if let milk = Double(milkGoalText) {
            viewModel.milkGoal = max(1.0, milk)
        } else {
            viewModel.milkGoal = max(1.0, viewModel.milkGoal)
        }
        if let eggs = Double(eggsGoalText) {
            viewModel.eggsGoal = max(1.0, eggs)
        } else {
            viewModel.eggsGoal = max(1.0, viewModel.eggsGoal)
        }
        if let wool = Double(woolGoalText) {
            viewModel.woolGoal = max(1.0, wool)
        } else {
            viewModel.woolGoal = max(1.0, viewModel.woolGoal)
        }
        viewModel.saveGoals()
    }
    
    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

