//
//  WorkHourViewModel.swift
//  LogWorkTime
//
//  Created by Kurt De Jonghe on 31/12/2025.
//

import Foundation
internal import Combine
internal import SwiftUI

class WorkHourViewModel: ObservableObject {
    @State private var breakTime: Double = 0.50
    @Published var workHours: [WorkHour] = [] {
        didSet {
            saveWorkHours()
        }
    }
    
    func addWorkHour(date: Date, start: Date, end: Date) {
        let newWorkHour = WorkHour(startDate: date, startTime: start, endTime: end)
        workHours.append(newWorkHour)
    }
    
    func removeWorkhour(at index: IndexSet) {
        workHours.remove(atOffsets: index)
    }
    
    func saveWorkHours() {
        if let encoded = try? JSONEncoder().encode(workHours) {
            UserDefaults.standard.set(encoded, forKey: "workHours")
        }
    }
    
    func loadWorkHours() {
        if let savedData = UserDefaults.standard.data(forKey: "workHours"),
           let decoded = try? JSONDecoder().decode([WorkHour].self, from: savedData) {
            workHours = decoded
        }
    }
    
    func currentYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
    
    func updateWorkHours(workHour: WorkHour, newEndTime: Date) {
        if let index = workHours.firstIndex(where: { $0.id == workHour.id }) {
            workHours[index].updateHours(newEndTime: newEndTime)
        }
    }
    
    var totalHours: Double {
        workHours.reduce(0) { $0 + ($1.hours - breakTime) }
    }
    
    var dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    var itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}



