//
//  TransactionModels.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 04/02/26.
//

import Foundation
import SwiftData

enum TransactionType: String, Codable, CaseIterable {
    case income
    case expense
}

@Model
final class TransactionItem {
    var type: TransactionType
    var date: Date
    var title: String
    var amount: Double

    init(type: TransactionType, date: Date, title: String, amount: Double) {
        self.type = type
        self.date = date
        self.title = title
        self.amount = amount
    }
}

