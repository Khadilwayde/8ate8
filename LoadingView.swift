import SwiftUI

struct LoadingView: View {
    @State private var pulse = false
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(pulse ? 0 : 0.25), lineWidth: 1.5)
                        .frame(width: pulse ? 90 : 48, height: pulse ? 90 : 48)
                        .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulse)
                    Circle()
                        .stroke(Color.blue.opacity(pulse ? 0 : 0.12), lineWidth: 1.5)
                        .frame(width: pulse ? 120 : 48, height: pulse ? 120 : 48)
                        .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.3), value: pulse)
                    Circle()
                        .fill(Color(red: 0.04, green: 0.52, blue: 1.0))
                        .frame(width: 48, height: 48)
                        .overlay {
                            Image(systemName: "waveform")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                }
                Text("ChatterBox")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .onAppear { pulse = true }
    }
}
