//
//  EditMonthlyLimitSheet.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 05/02/26.
//


import SwiftUI
import SwiftData

struct EditMonthlyLimitSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var limit: MonthlyDailyLimit
    @State private var amountText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Daily Limit", text: $amountText)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Edit Daily Limit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        limit.dailyLimit = Double(amountText) ?? limit.dailyLimit
                        dismiss()
                    }
                    .disabled(Double(amountText) == nil)
                }
            }
        }
        .onAppear {
            amountText = String(limit.dailyLimit)
        }
    }
}
