import Foundation

enum CurrencyFormatter {
    static let inr: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.currencyCode = "INR"
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    static let compact: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static func inrCompactString(_ value: Double) -> String {
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""

        if absValue >= 1e7 {
            let num = absValue / 1e7
            let formatted = compact.string(from: NSNumber(value: num)) ?? "0"
            return "\(sign)₹\(formatted)Cr"
        }

        if absValue >= 1e5 {
            let num = absValue / 1e5
            let formatted = compact.string(from: NSNumber(value: num)) ?? "0"
            return "\(sign)₹\(formatted)L"
        }

        return sign + (inr.string(from: NSNumber(value: absValue)) ?? "₹0.00")
    }


    static func inrString(_ value: Double) -> String {
        inr.string(from: NSNumber(value: value)) ?? "₹0"
    }
}
