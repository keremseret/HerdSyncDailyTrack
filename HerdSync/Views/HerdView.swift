import SwiftUI
import CoreData

struct HerdView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HerdViewModel
    @State private var showingAddHerd = false
    @State private var editingHerd: Herd?
    
    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: HerdViewModel(viewContext: viewContext))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.herds.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(LocalizedString("herd.empty"))
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button(action: {
                            showingAddHerd = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(LocalizedString("herd.add"))
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.herds, id: \.id) { herd in
                            HerdRow(herd: herd, viewModel: viewModel, editingHerd: $editingHerd)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        viewModel.deleteHerd(herd)
                                    } label: {
                                        Text(LocalizedString("common.delete"))
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle(LocalizedString("herd.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddHerd = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHerd) {
                HerdEditView(viewModel: viewModel, herd: nil)
            }
            .sheet(item: $editingHerd) { herd in
                HerdEditView(viewModel: viewModel, herd: herd)
            }
        }
    }
}

struct HerdRow: View {
    let herd: Herd
    @ObservedObject var viewModel: HerdViewModel
    @Binding var editingHerd: Herd?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(herd.name ?? "")
                .font(.headline)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "pawprint.fill")
                    Text("\(herd.cows)")
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "bird.fill")
                    Text("\(herd.chickens)")
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "pawprint")
                    Text("\(herd.sheep)")
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "pawprint.circle")
                    Text("\(herd.goats)")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            editingHerd = herd
        }
    }
}

struct HerdEditView: View {
    @ObservedObject var viewModel: HerdViewModel
    let herd: Herd?
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var cows: Int32 = 0
    @State private var chickens: Int32 = 0
    @State private var sheep: Int32 = 0
    @State private var goats: Int32 = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(LocalizedString("herd.name"), text: $name)
                }
                
                Section {
                    Stepper(value: $cows, in: 0...1000) {
                        HStack {
                            Text(LocalizedString("herd.cows"))
                            Spacer()
                            Text("\(cows)")
                        }
                    }
                    
                    Stepper(value: $chickens, in: 0...10000) {
                        HStack {
                            Text(LocalizedString("herd.chickens"))
                            Spacer()
                            Text("\(chickens)")
                        }
                    }
                    
                    Stepper(value: $sheep, in: 0...1000) {
                        HStack {
                            Text(LocalizedString("herd.sheep"))
                            Spacer()
                            Text("\(sheep)")
                        }
                    }
                    
                    Stepper(value: $goats, in: 0...1000) {
                        HStack {
                            Text(LocalizedString("herd.goats"))
                            Spacer()
                            Text("\(goats)")
                        }
                    }
                }
                
                Section {
                    Button(action: save) {
                        HStack {
                            Spacer()
                            Text(LocalizedString("herd.save"))
                            Spacer()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle(herd == nil ? LocalizedString("herd.add") : LocalizedString("herd.edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedString("common.cancel")) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let herd = herd {
                    name = herd.name ?? ""
                    cows = herd.cows
                    chickens = herd.chickens
                    sheep = herd.sheep
                    goats = herd.goats
                }
            }
        }
    }
    
    private func save() {
        if let herd = herd {
            viewModel.updateHerd(herd, name: name, cows: cows, chickens: chickens, sheep: sheep, goats: goats)
        } else {
            viewModel.addHerd(name: name, cows: cows, chickens: chickens, sheep: sheep, goats: goats)
        }
        dismiss()
    }
}

