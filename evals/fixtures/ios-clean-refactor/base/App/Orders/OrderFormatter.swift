import Foundation

struct Order: Identifiable {
    let id: String
    let placedAt: Date
    let totalCents: Int
    let itemCount: Int
}

enum OrderFormatter {
    static func placedLabel(for order: Order) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Placed " + formatter.string(from: order.placedAt)
    }

    static func receiptLine(for order: Order) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let date = formatter.string(from: order.placedAt)
        let total = String(format: "%.2f", Double(order.totalCents) / 100)
        return "#\(order.id) · \(date) · \(total)"
    }
}
