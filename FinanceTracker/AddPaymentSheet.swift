//
//  AddPaymentSheet.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 05/02/26.
//


import SwiftUI
import SwiftData

struct AddPaymentSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var editingPayment: UpcomingPayment? = nil

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var dueDate: Date = Date()

    private var isEditing: Bool { editingPayment != nil }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Payment Name", text: $title)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
            }
            .navigationTitle(isEditing ? "Edit Payment" : "Add Payment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        let value = Double(amount) ?? 0

                        if let payment = editingPayment {
                            payment.title = title
                            payment.amount = value
                            payment.dueDate = dueDate
                        } else {
                            let item = UpcomingPayment(title: title, amount: value, dueDate: dueDate)
                            modelContext.insert(item)
                        }

                        dismiss()
                    }
                    .disabled(title.isEmpty || Double(amount) == nil)
                }
            }
        }
        .onAppear {
            if let payment = editingPayment {
                title = payment.title
                amount = String(payment.amount)
                dueDate = payment.dueDate
            }
        }
    }
}
