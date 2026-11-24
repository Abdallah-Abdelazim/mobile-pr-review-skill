import SwiftUI

struct OrderRow: View {
    let order: Order

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("#\(order.id)")
                    .font(.headline)
                Text(OrderFormatter.placedLabel(for: order))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.2f", Double(order.totalCents) / 100))
                    .font(.headline)
                    .monospacedDigit()
                Text(order.itemCount == 1 ? "1 item" : "\(order.itemCount) items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
