import Foundation
import SwiftData

@Model
final class ExpensePreset {
    var title: String
    var amount: Double
    var createdAt: Date

    init(title: String, amount: Double, createdAt: Date = Date()) {
        self.title = title
        self.amount = amount
        self.createdAt = createdAt
    }
}
