import SwiftUI
import CoreData

struct PlanView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: PlanViewModel
    
    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: PlanViewModel(viewContext: viewContext))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.todayPlan.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text(LocalizedString("herd.noHerds"))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(viewModel.todayPlan, id: \.type) { plan in
                            PlanCard(plan: plan, viewModel: viewModel)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(LocalizedString("plan.title"))
            .onAppear {
                viewModel.loadTodayPlan()
            }
        }
    }
}

struct PlanCard: View {
    let plan: ProductPlan
    @ObservedObject var viewModel: PlanViewModel
    @State private var editingValue: String = ""
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(plan.type.localizedName)
                    .font(.headline)
                Spacer()
                if plan.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(LocalizedString("plan.required"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(formatValue(plan.required)) \(plan.type.unit)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(LocalizedString("plan.actual"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if isEditing {
                        TextField("", text: $editingValue)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                            .onSubmit {
                                saveValue()
                            }
                    } else {
                        Text("\(formatValue(plan.actual)) \(plan.type.unit)")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            ProgressView(value: plan.progress)
                .tint(plan.isCompleted ? .green : .blue)
            
            HStack {
                Spacer()
                if isEditing {
                    Button(LocalizedString("common.save")) {
                        saveValue()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(LocalizedString("common.edit")) {
                        editingValue = ""
                        isEditing = true
                    }
                    .buttonStyle(.bordered)
                }
            }
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
    
    private func saveValue() {
        if let value = Double(editingValue) {
            viewModel.updateRecord(product: plan.type, value: value)
        }
        isEditing = false
    }
}

