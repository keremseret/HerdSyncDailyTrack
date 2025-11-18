import Foundation
import CoreData
import SwiftUI
import Combine

class PlanViewModel: ObservableObject {
    @Published var todayPlan: [ProductPlan] = []
    @Published var todayRecord: DailyRecord?
    
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        loadTodayPlan()
    }
    
    func loadTodayPlan() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let herdRequest: NSFetchRequest<Herd> = Herd.fetchRequest()
        guard let herds = try? viewContext.fetch(herdRequest) else {
            return
        }
        
        let goalRequest: NSFetchRequest<DailyGoal> = DailyGoal.fetchRequest()
        goalRequest.predicate = NSPredicate(format: "date == %@", today as NSDate)
        let goals = try? viewContext.fetch(goalRequest)
        let todayGoal = goals?.first
        
        let recordRequest: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        recordRequest.predicate = NSPredicate(format: "date == %@", today as NSDate)
        let records = try? viewContext.fetch(recordRequest)
        todayRecord = records?.first
        
        if let record = todayRecord {
            checkCompletion(record: record)
            try? viewContext.save()
        }
        
        var totalCows = 0
        var totalChickens = 0
        var totalSheep = 0
        
        for herd in herds {
            totalCows += Int(herd.cows)
            totalChickens += Int(herd.chickens)
            totalSheep += Int(herd.sheep)
        }
        
        var plan: [ProductPlan] = []
        
        let milkRequired = todayGoal?.milk ?? max(1.0, Double(totalCows * 20))
        let milkActual = todayRecord?.milk ?? 0
        plan.append(ProductPlan(type: .milk, required: milkRequired, actual: milkActual))
        
        let eggsRequired = Double(todayGoal?.eggs ?? Int32(max(1.0, Double(totalChickens * 5))))
        let eggsActual = Double(todayRecord?.eggs ?? 0)
        plan.append(ProductPlan(type: .eggs, required: eggsRequired, actual: eggsActual))
        
        let woolRequired = todayGoal?.wool ?? max(1.0, Double(totalSheep * 2))
        let woolActual = todayRecord?.wool ?? 0
        plan.append(ProductPlan(type: .wool, required: woolRequired, actual: woolActual))
        
        todayPlan = plan
    }
    
    func updateRecord(product: ProductType, value: Double) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if todayRecord == nil {
            let newRecord = DailyRecord(context: viewContext)
            newRecord.id = UUID()
            newRecord.date = today
            newRecord.milk = 0
            newRecord.eggs = 0
            newRecord.wool = 0
            newRecord.isCompleted = false
            todayRecord = newRecord
        }
        
        guard let record = todayRecord else { return }
        
        switch product {
        case .milk:
            record.milk = value
        case .eggs:
            record.eggs = Int32(value)
        case .wool:
            record.wool = value
        }
        
        checkCompletion(record: record)
        
        do {
            try viewContext.save()
            NotificationCenter.default.post(name: .recordUpdated, object: nil)
            loadTodayPlan()
        } catch {
            print("Error saving record: \(error)")
        }
    }
    
    private func checkCompletion(record: DailyRecord) {
        guard let recordDate = record.date else {
            record.isCompleted = false
            return
        }
        
        let calendar = Calendar.current
        let recordDay = calendar.startOfDay(for: recordDate)
        
        let goalRequest: NSFetchRequest<DailyGoal> = DailyGoal.fetchRequest()
        goalRequest.predicate = NSPredicate(format: "date == %@", recordDay as NSDate)
        guard let goals = try? viewContext.fetch(goalRequest),
              let goal = goals.first else {
            record.isCompleted = false
            return
        }
        
        var allCompleted = true
        var hasAnyCheck = false
        
        let milkOk = record.milk >= goal.milk
        allCompleted = allCompleted && milkOk
        hasAnyCheck = true
        
        let eggsOk = Double(record.eggs) >= Double(goal.eggs)
        allCompleted = allCompleted && eggsOk
        hasAnyCheck = true
        
        let woolOk = record.wool >= goal.wool
        allCompleted = allCompleted && woolOk
        hasAnyCheck = true
        
        record.isCompleted = hasAnyCheck && allCompleted
    }
}

struct ProductPlan {
    let type: ProductType
    let required: Double
    let actual: Double
    
    var isCompleted: Bool {
        actual >= required
    }
    
    var progress: Double {
        guard required > 0 else { return 0 }
        return min(actual / required, 1.0)
    }
}

