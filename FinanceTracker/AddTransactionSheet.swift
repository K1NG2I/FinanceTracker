//
//  AddTransactionSheet.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 05/02/26.
//

import SwiftUI
import SwiftData

struct AddTransactionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let type: TransactionType
    let selectedMonth: Date
    var editingItem: TransactionItem? = nil

    @State private var date: Date = Date()
    @State private var title: String = ""
    @State private var amount: String = ""

    var isEditing: Bool { editingItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                TextField(type == .income ? "Source" : "Payee", text: $title)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle(isEditing ? "Edit \(type == .income ? "Income" : "Expense")" : (type == .income ? "Add Income" : "Add Expense"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        let value = Double(amount) ?? 0

                        if let item = editingItem {
                            item.date = date
                            item.title = title
                            item.amount = value
                        } else {
                            let item = TransactionItem(type: type, date: date, title: title, amount: value)
                            modelContext.insert(item)
                        }

                        dismiss()
                    }
                    .disabled(title.isEmpty || Double(amount) == nil)
                }
            }
        }
        .onAppear {
            if let item = editingItem {
                date = item.date
                title = item.title
                amount = String(item.amount)
            } else {
                date = selectedMonth
            }
        }
    }
}
