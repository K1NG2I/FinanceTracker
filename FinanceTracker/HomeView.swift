//
//  HomeView.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 05/02/26.
//

import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @Query private var allItems: [TransactionItem]
    @Query private var limits: [MonthlyDailyLimit]
    @Query private var payments: [UpcomingPayment]

    @State private var selectedMonth: Date = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    MonthYearPicker(selectedDate: $selectedMonth)

                    heroCard

                    chartsRow

                    kpiGrid

                    upcomingPaymentsCard
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    private var heroCard: some View {
        let now = Date()
        let allTimeIncome = sum(type: .income, from: .distantPast, to: now)
        let allTimeExpense = sum(type: .expense, from: .distantPast, to: now)
        let balanceToday = allTimeIncome - allTimeExpense

        return VStack(alignment: .leading, spacing: 8) {
            Text("Balance Today (All-Time)")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.inrCompactString(balanceToday))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(balanceToday >= 0 ? .green : .red)
            Text("All income minus all expenses")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var chartsRow: some View {
        VStack(spacing: 16) {
            donutCard
            barChartCard
        }
    }

    private var donutCard: some View {
        let monthStart = selectedMonth.startOfMonth()
        let monthEnd = selectedMonth.endOfMonth()
        let income = sum(type: .income, from: monthStart, to: monthEnd)
        let expense = sum(type: .expense, from: monthStart, to: monthEnd)

        let slices: [DonutSlice] = [
            DonutSlice(label: "Income", value: max(income, 0), color: .green),
            DonutSlice(label: "Expense", value: max(expense, 0), color: .red)
        ]

        return VStack(alignment: .leading, spacing: 12) {
            Text("Income vs Expense (Month)")
                .font(.headline)

            if income + expense == 0 {
                Text("No data for this month")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                Chart(slices) { slice in
                    SectorMark(
                        angle: .value("Amount", slice.value),
                        innerRadius: .ratio(0.65)
                    )
                    .foregroundStyle(slice.color)
                }
                .frame(height: 180)

                HStack(spacing: 16) {
                    legendItem(label: "Income", color: .green, value: income)
                    legendItem(label: "Expense", color: .red, value: expense)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func legendItem(label: String, color: Color, value: Double) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.inrCompactString(value))
                    .font(.caption.weight(.semibold))
            }
        }
    }

    private var barChartCard: some View {
        let points = dailyExpensePoints(for: selectedMonth)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Daily Expense (Month)")
                .font(.headline)

            if points.allSatisfy({ $0.amount == 0 }) {
                Text("No expense data for this month")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                Chart(points) { point in
                    BarMark(
                        x: .value("Day", point.date),
                        y: .value("Expense", point.amount)
                    )
                    .foregroundStyle(.orange)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 5)) { value in
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var kpiGrid: some View {
        let monthStart = selectedMonth.startOfMonth()
        let monthEnd = selectedMonth.endOfMonth()
        let yearStart = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: selectedMonth), month: 1, day: 1)) ?? Date()
        let yearEnd = Calendar.current.date(byAdding: DateComponents(year: 1, day: -1), to: yearStart) ?? Date()

        let monthlyIncome = sum(type: .income, from: monthStart, to: monthEnd)
        let monthlyExpense = sum(type: .expense, from: monthStart, to: monthEnd)
        let yearlyIncome = sum(type: .income, from: yearStart, to: yearEnd)
        let yearlyExpense = sum(type: .expense, from: yearStart, to: yearEnd)

        let selectedKey = selectedMonth.startOfMonth()
        let dailyLimit = limits.first { Calendar.current.isDate($0.monthKey, equalTo: selectedKey, toGranularity: .month) }?.dailyLimit ?? 0
        let todayExpense = sum(type: .expense, from: Calendar.current.startOfDay(for: Date()), to: Date())
        let todaySavings = dailyLimit - todayExpense

        let items: [(String, Double, Color)] = [
            ("Yearly Income", yearlyIncome, .green),
            ("Yearly Expense", yearlyExpense, .red),
            ("Monthly Income", monthlyIncome, .green),
            ("Monthly Expense", monthlyExpense, .red),
            ("Daily Limit", dailyLimit, .blue),
            ("Today’s Savings", todaySavings, todaySavings >= 0 ? .green : .red)
        ]

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(items, id: \.0) { item in
                kpiCard(title: item.0, value: item.1, color: item.2)
            }
        }
    }

    private func kpiCard(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.inrCompactString(value))
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var upcomingPaymentsCard: some View {
        let upcoming = payments
            .filter { $0.dueDate >= Calendar.current.startOfDay(for: Date()) }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(3)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Upcoming Payments")
                .font(.headline)

            if upcoming.isEmpty {
                Text("No upcoming payments yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(upcoming) { p in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(p.title)
                            Text(p.dueDate, format: .dateTime.month().day().year())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(CurrencyFormatter.inrCompactString(p.amount))
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func dailyExpensePoints(for month: Date) -> [DailyExpensePoint] {
        let days = Calendar.current.datesInMonth(for: month)
        return days.map { day in
            let start = Calendar.current.startOfDay(for: day)
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
            let amount = sum(type: .expense, from: start, to: end)
            return DailyExpensePoint(date: day, amount: amount)
        }
    }

    private func sum(type: TransactionType, from: Date, to: Date) -> Double {
        allItems
            .filter { $0.type == type && $0.date >= from && $0.date <= to }
            .map(\.amount)
            .reduce(0, +)
    }
}
