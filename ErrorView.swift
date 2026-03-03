import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1, green: 0.27, blue: 0.23).opacity(0.12))
                            .frame(width: 72, height: 72)
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(Color(red: 1, green: 0.27, blue: 0.23))
                    }
                    Text("No Connection")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                    Text(message.isEmpty
                         ? "ChatterBox couldn't connect.\nCheck internet and try again."
                         : message)
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                }
                Button(action: onRetry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 240)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.04, green: 0.52, blue: 1),
                                    in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
        }
    }
}
