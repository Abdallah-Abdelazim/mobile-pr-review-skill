import Foundation

struct Order: Identifiable {
    let id: String
    let placedAt: Date
    let totalCents: Int
    let itemCount: Int
}

enum OrderFormatter {
    static func placedLabel(for order: Order) -> String {
        "Placed " + dateText(order.placedAt)
    }

    static func receiptLine(for order: Order) -> String {
        "#\(order.id) · \(dateText(order.placedAt)) · \(totalText(order.totalCents))"
    }

    static func totalText(_ cents: Int) -> String {
        String(format: "%.2f", Double(cents) / 100)
    }

    private static func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
