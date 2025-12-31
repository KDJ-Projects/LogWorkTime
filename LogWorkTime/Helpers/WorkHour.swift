//
//  WorkHour.swift
//  LogWorkTime
//
//  Created by Kurt De Jonghe on 31/12/2025.
//

import Foundation

struct WorkHour: Identifiable, Codable {
    var id = UUID()
    var startDate: Date
    var startTime: Date
    var endTime: Date
    
    var hours: Double {
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    mutating func updateHours(newEndTime: Date) {
        self.endTime = newEndTime
    }
}


