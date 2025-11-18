import Foundation
import CoreData
import SwiftUI
import Combine

class StatisticsViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var records: [DailyRecord] = []
    @Published var completionRate: Double = 0
    @Published var hasHerds: Bool = false
    
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        loadStatistics()
        
        NotificationCenter.default.publisher(for: .dataReset)
            .sink { [weak self] _ in
                self?.loadStatistics()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .recordUpdated)
            .sink { [weak self] _ in
                self?.loadStatistics()
            }
            .store(in: &cancellables)
    }
    
    func loadStatistics() {
        viewContext.refreshAllObjects()
        
        let herdRequest: NSFetchRequest<Herd> = Herd.fetchRequest()
        if let herds = try? viewContext.fetch(herdRequest) {
            var totalCows = 0
            var totalChickens = 0
            var totalSheep = 0
            
            for herd in herds {
                totalCows += Int(herd.cows)
                totalChickens += Int(herd.chickens)
                totalSheep += Int(herd.sheep)
            }
            
            hasHerds = totalCows > 0 || totalChickens > 0 || totalSheep > 0
            
            if !hasHerds {
                records = []
                completionRate = 0
                return
            }
        } else {
            hasHerds = false
            records = []
            completionRate = 0
            return
        }
        
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        let request: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfMonth as NSDate, endOfMonth as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyRecord.date, ascending: false)]
        
        if let fetched = try? viewContext.fetch(request) {
            records = fetched
            recalculateCompletionForAllRecords()
            viewContext.refreshAllObjects()
            if let fetchedAgain = try? viewContext.fetch(request) {
                records = fetchedAgain
            }
            calculateCompletionRate()
        }
    }
    
    private func recalculateCompletionForAllRecords() {
        let calendar = Calendar.current
        var hasChanges = false
        
        for record in records {
            guard let recordDate = record.date else { continue }
            let recordDay = calendar.startOfDay(for: recordDate)
            
            let goalRequest: NSFetchRequest<DailyGoal> = DailyGoal.fetchRequest()
            goalRequest.predicate = NSPredicate(format: "date == %@", recordDay as NSDate)
            guard let goals = try? viewContext.fetch(goalRequest),
                  let goal = goals.first else {
                if record.isCompleted {
                    record.isCompleted = false
                    hasChanges = true
                }
                continue
            }
            
            let milkOk = record.milk >= goal.milk
            let eggsOk = Double(record.eggs) >= Double(goal.eggs)
            let woolOk = record.wool >= goal.wool
            
            let newIsCompleted = milkOk && eggsOk && woolOk
            if record.isCompleted != newIsCompleted {
                record.isCompleted = newIsCompleted
                hasChanges = true
            }
        }
        
        if hasChanges {
            try? viewContext.save()
        }
    }
    
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        loadStatistics()
    }
    
    private func calculateCompletionRate() {
        guard !records.isEmpty else {
            completionRate = 0
            return
        }
        
        let completed = records.filter { $0.isCompleted }.count
        completionRate = Double(completed) / Double(records.count) * 100
    }
    
    func getRecordsForDate(_ date: Date) -> DailyRecord? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        return records.first { record in
            guard let recordDate = record.date else { return false }
            return calendar.isDate(recordDate, inSameDayAs: startOfDay)
        }
    }
}

