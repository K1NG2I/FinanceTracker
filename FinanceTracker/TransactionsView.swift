//
//  TransactionsView.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 04/02/26.
//

import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [TransactionItem]
    @Query private var presets: [ExpensePreset]

    @State private var selectedMonth: Date = Date()
    @State private var showAddSheet = false
    @State private var addType: TransactionType = .income
    @State private var selectedType: TransactionType = .income
    @State private var editingItem: TransactionItem?

    @State private var showPresetSheet = false
    @State private var editingPreset: ExpensePreset?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                MonthYearPicker(selectedDate: $selectedMonth)

                Picker("Type", selection: $selectedType) {
                    Text("Income").tag(TransactionType.income)
                    Text("Expense").tag(TransactionType.expense)
                }
                .pickerStyle(.segmented)

                List {
                    if selectedType == .expense {
                        Section("Presets") {
                            let sortedPresets = presets.sorted { $0.createdAt > $1.createdAt }
                            if sortedPresets.isEmpty {
                                Text("No presets yet")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(sortedPresets) { preset in
                                    presetRow(preset)
                                }
                            }
                        }
                    }

                    Section {
                        let items = filteredItems(of: selectedType)
                        let label = (selectedType == .income) ? "Source" : "Payee"

                        if items.isEmpty {
                            Text("No \(selectedType == .income ? "income" : "expense") for this month.")
                                .foregroundStyle(.secondary)
                        } else {
                            tableHeader(label: label)
                            ForEach(items) { item in
                                tableRow(item: item)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .padding(.horizontal)
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Add Transaction") {
                            addType = selectedType
                            showAddSheet = true
                        }
                        Button("Add Preset") {
                            showPresetSheet = true
                        }
                        .disabled(selectedType != .expense)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddTransactionSheet(type: addType, selectedMonth: selectedMonth)
            }
            .sheet(item: $editingItem) { item in
                AddTransactionSheet(type: item.type, selectedMonth: selectedMonth, editingItem: item)
            }
            .sheet(isPresented: $showPresetSheet) {
                ExpensePresetSheet()
            }
            .sheet(item: $editingPreset) { preset in
                ExpensePresetSheet(editingPreset: preset)
            }
        }
    }

    private func presetRow(_ preset: ExpensePreset) -> some View {
        HStack {
            Text(preset.title)
            Spacer()
            Text(CurrencyFormatter.inrString(preset.amount))
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .leading) {
            Button {
                editingPreset = preset
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)

            Button(role: .destructive) {
                modelContext.delete(preset)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing) {
            Button {
                let item = TransactionItem(type: .expense, date: Date(), title: preset.title, amount: preset.amount)
                modelContext.insert(item)
            } label: {
                Label("Add Today", systemImage: "plus.circle.fill")
            }
            .tint(.green)
        }
    }

    private func tableHeader(label: String) -> some View {
        HStack {
            Text("Date").frame(width: 90, alignment: .leading)
            Text(label).frame(maxWidth: .infinity, alignment: .leading)
            Text("Amount").frame(width: 90, alignment: .trailing)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.vertical, 4)
    }

    private func tableRow(item: TransactionItem) -> some View {
        HStack {
            Text(item.date, format: .dateTime.month().day())
                .frame(width: 90, alignment: .leading)
            Text(item.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(CurrencyFormatter.inrString(item.amount))
                .frame(width: 90, alignment: .trailing)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .leading) {
            Button {
                editingItem = item
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)

            Button(role: .destructive) {
                modelContext.delete(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func filteredItems(of type: TransactionType) -> [TransactionItem] {
        let start = selectedMonth.startOfMonth()
        let end = selectedMonth.endOfMonth()

        return allItems
            .filter { $0.type == type && $0.date >= start && $0.date <= end }
            .sorted { $0.date > $1.date }
    }
}
