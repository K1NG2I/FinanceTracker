//
//  FutureView.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 05/02/26.
//

import SwiftUI
import SwiftData

struct FutureView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var limits: [MonthlyDailyLimit]
    @Query private var payments: [UpcomingPayment]

    @State private var selectedMonth: Date = Date()
    @State private var showAddPayment = false
    @State private var editingPayment: UpcomingPayment?
    @State private var editingLimit: MonthlyDailyLimit?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                dailyLimitSection

                List {
                    Section {
                        if payments.isEmpty {
                            Text("No upcoming payments yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(payments.sorted(by: { $0.dueDate < $1.dueDate })) { p in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(p.title)
                                        Text(p.dueDate, format: .dateTime.month().day().year())
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(CurrencyFormatter.inrString(p.amount))
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        editingPayment = p
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)

                                    Button(role: .destructive) {
                                        modelContext.delete(p)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Upcoming Payments")
                    }
                }
                .listStyle(.plain)
            }
            .padding(.horizontal)
            .navigationTitle("Future")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddPayment = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPayment) {
                AddPaymentSheet()
            }
            .sheet(item: $editingPayment) { payment in
                AddPaymentSheet(editingPayment: payment)
            }
            .sheet(item: $editingLimit) { limit in
                EditMonthlyLimitSheet(limit: limit)
            }
        }
    }

    private var dailyLimitSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MonthYearPicker(selectedDate: $selectedMonth)

            List {
                if let limit = limitForSelectedMonth() {
                    HStack {
                        Text("Daily Limit")
                        Spacer()
                        Text(CurrencyFormatter.inrString(limit.dailyLimit))
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            editingLimit = limit
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                } else {
                    HStack {
                        Text("Daily Limit")
                        Spacer()
                        Text("Not set")
                            .foregroundStyle(.secondary)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            let newLimit = MonthlyDailyLimit(monthKey: selectedMonth.startOfMonth(), dailyLimit: 0)
                            modelContext.insert(newLimit)
                            editingLimit = newLimit
                        } label: {
                            Label("Set", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .listStyle(.plain)
            .frame(height: 60)
        }
    }

    private func limitForSelectedMonth() -> MonthlyDailyLimit? {
        let key = selectedMonth.startOfMonth()
        return limits.first { Calendar.current.isDate($0.monthKey, equalTo: key, toGranularity: .month) }
    }
}
