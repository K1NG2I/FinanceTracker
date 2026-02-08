//
//  DateHelpers.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 04/02/26.
//

import Foundation

extension Date {
    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }

    func endOfMonth() -> Date {
        let start = startOfMonth()
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: start) ?? self
    }
}
