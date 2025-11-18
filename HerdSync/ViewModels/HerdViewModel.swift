import Foundation
import CoreData
import SwiftUI
import Combine

class HerdViewModel: ObservableObject {
    @Published var herds: [Herd] = []
    
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        loadHerds()
        
        NotificationCenter.default.publisher(for: .dataReset)
            .sink { [weak self] _ in
                self?.loadHerds()
            }
            .store(in: &cancellables)
    }
    
    func loadHerds() {
        let request: NSFetchRequest<Herd> = Herd.fetchRequest()
        if let fetched = try? viewContext.fetch(request) {
            herds = fetched
        }
    }
    
    func addHerd(name: String, cows: Int32, chickens: Int32, sheep: Int32, goats: Int32) {
        let herd = Herd(context: viewContext)
        herd.id = UUID()
        herd.name = name
        herd.cows = cows
        herd.chickens = chickens
        herd.sheep = sheep
        herd.goats = goats
        
        do {
            try viewContext.save()
            loadHerds()
        } catch {
            print("Error adding herd: \(error)")
        }
    }
    
    func updateHerd(_ herd: Herd, name: String, cows: Int32, chickens: Int32, sheep: Int32, goats: Int32) {
        herd.name = name
        herd.cows = cows
        herd.chickens = chickens
        herd.sheep = sheep
        herd.goats = goats
        
        do {
            try viewContext.save()
            loadHerds()
        } catch {
            print("Error updating herd: \(error)")
        }
    }
    
    func deleteHerd(_ herd: Herd) {
        viewContext.delete(herd)
        do {
            try viewContext.save()
            loadHerds()
        } catch {
            print("Error deleting herd: \(error)")
        }
    }
}

