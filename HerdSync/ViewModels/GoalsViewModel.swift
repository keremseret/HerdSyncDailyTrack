import Foundation
import CoreData
import SwiftUI
import Combine

class GoalsViewModel: ObservableObject {
    @Published var milkGoal: Double = 0
    @Published var eggsGoal: Double = 0
    @Published var woolGoal: Double = 0
    
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        loadTodayGoals()
    }
    
    func loadTodayGoals() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let request: NSFetchRequest<DailyGoal> = DailyGoal.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        if let goals = try? viewContext.fetch(request),
           let goal = goals.first {
            milkGoal = goal.milk
            eggsGoal = Double(goal.eggs)
            woolGoal = goal.wool
        } else {
            calculateDefaultGoals()
        }
    }
    
    private func calculateDefaultGoals() {
        let herdRequest: NSFetchRequest<Herd> = Herd.fetchRequest()
        var totalCows = 0
        var totalChickens = 0
        var totalSheep = 0
        
        if let herds = try? viewContext.fetch(herdRequest) {
            for herd in herds {
                totalCows += Int(herd.cows)
                totalChickens += Int(herd.chickens)
                totalSheep += Int(herd.sheep)
            }
        }
        
        milkGoal = max(1.0, Double(totalCows * 20))
        eggsGoal = max(1.0, Double(totalChickens * 5))
        woolGoal = max(1.0, Double(totalSheep * 2))
    }
    
    func saveGoals() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        milkGoal = max(1.0, milkGoal)
        eggsGoal = max(1.0, eggsGoal)
        woolGoal = max(1.0, woolGoal)
        
        let request: NSFetchRequest<DailyGoal> = DailyGoal.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        let goal: DailyGoal
        if let existing = try? viewContext.fetch(request).first {
            goal = existing
        } else {
            goal = DailyGoal(context: viewContext)
            goal.id = UUID()
            goal.date = today
        }
        
        goal.milk = milkGoal
        goal.eggs = Int32(eggsGoal)
        goal.wool = woolGoal
        
        do {
            try viewContext.save()
            NotificationCenter.default.post(name: .recordUpdated, object: nil)
        } catch {
            print("Error saving goals: \(error)")
        }
    }
}

