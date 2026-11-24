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
            OrderTotals(order: order)
        }
        .padding(.vertical, 8)
    }
}

private struct OrderTotals: View {
    let order: Order

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(OrderFormatter.totalText(order.totalCents))
                .font(.headline)
                .monospacedDigit()
            Text(order.itemCount == 1 ? "1 item" : "\(order.itemCount) items")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
