import SwiftUI
import SwiftData

struct ExpensePresetSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var editingPreset: ExpensePreset? = nil

    @State private var title: String = ""
    @State private var amount: String = ""

    private var isEditing: Bool { editingPreset != nil }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle(isEditing ? "Edit Preset" : "New Preset")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        let value = Double(amount) ?? 0

                        if let preset = editingPreset {
                            preset.title = title
                            preset.amount = value
                        } else {
                            let preset = ExpensePreset(title: title, amount: value)
                            modelContext.insert(preset)
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty || Double(amount) == nil)
                }
            }
        }
        .onAppear {
            if let preset = editingPreset {
                title = preset.title
                amount = String(preset.amount)
            }
        }
    }
}
