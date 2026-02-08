import Foundation
import SwiftUI

struct DonutSlice: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

struct DailyExpensePoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

extension Calendar {
    func datesInMonth(for month: Date) -> [Date] {
        let start = date(from: dateComponents([.year, .month], from: month)) ?? month
        guard let range = range(of: .day, in: .month, for: start) else { return [] }
        return range.compactMap { day -> Date? in
            date(from: DateComponents(year: component(.year, from: start),
                                      month: component(.month, from: start),
                                      day: day))
        }
    }
}
