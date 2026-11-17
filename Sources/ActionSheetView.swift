import SwiftUI

/// 底部弹出的玻璃操作面板
struct ActionSheetView: View {
    let brand: Color
    var onRefresh: () -> Void
    var onSearch: () -> Void
    var onSettings: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: 20) {
                Capsule()
                    .fill(.secondary.opacity(0.35))
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)

                HStack(spacing: 18) {
                    item("刷新", "arrow.clockwise") {
                        onRefresh(); dismiss()
                    }
                    item("搜索", "magnifyingglass") {
                        onSearch(); dismiss()
                    }
                    item("设置", "gearshape.fill") {
                        onSettings(); dismiss()
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 0)
            }
        }
        .presentationDetents([.height(180)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }

    private func item(_ title: String, _ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 54, height: 54)
                    .glassEffect(.regular.interactive(), in: Circle())
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
