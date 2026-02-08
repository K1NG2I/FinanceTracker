//
//  FutureModels.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 05/02/26.
//

import Foundation
import SwiftData

@Model
final class MonthlyDailyLimit {
    var monthKey: Date   // first day of the month
    var dailyLimit: Double

    init(monthKey: Date, dailyLimit: Double) {
        self.monthKey = monthKey
        self.dailyLimit = dailyLimit
    }
}

@Model
final class UpcomingPayment {
    var title: String
    var amount: Double
    var dueDate: Date

    init(title: String, amount: Double, dueDate: Date) {
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
    }
}
