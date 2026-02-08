//
//  MonthYearPicker.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 05/02/26.
//

import SwiftUI

struct MonthYearPicker: View {
    @Binding var selectedDate: Date
    @State private var showSheet = false

    var body: some View {
        HStack {
            Text("Month")
                .font(.headline)
            Spacer()
            Button {
                showSheet = true
            } label: {
                Text(selectedDate, format: .dateTime.year().month())
                    .font(.headline)
            }
        }
        .sheet(isPresented: $showSheet) {
            MonthYearPickerSheet(selectedDate: $selectedDate)
        }
    }
}

struct MonthYearPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date

    @State private var month: Int = 1
    @State private var year: Int = Calendar.current.component(.year, from: Date())

    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 0) {
                    Picker("Month", selection: $month) {
                        ForEach(1...12, id: \.self) { m in
                            Text(Calendar.current.monthSymbols[m - 1]).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Picker("Year", selection: $year) {
                        ForEach((year - 20)...(year + 20), id: \.self) { y in
                            Text(String(y)).tag(y)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
            }
            .onAppear {
                let comps = Calendar.current.dateComponents([.month, .year], from: selectedDate)
                month = comps.month ?? 1
                year = comps.year ?? Calendar.current.component(.year, from: Date())
            }
            .navigationTitle("Select Month")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if let newDate = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1)) {
                            selectedDate = newDate
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
