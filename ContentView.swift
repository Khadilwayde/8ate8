import SwiftUI

struct ContentView: View {
    @StateObject  private var webVM = WebViewModel()
    @EnvironmentObject var settingsVM: SettingsViewModel
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            WebViewContainer(viewModel: webVM).ignoresSafeArea()

            if webVM.isLoading {
                LoadingView().transition(.opacity).zIndex(1)
            }
            if webVM.hasError {
                ErrorView(message: webVM.errorMsg) { webVM.reload() }
                    .transition(.opacity).zIndex(2)
            }

            VStack {
                HStack {
                    Spacer()
                    Button { showSettings = true } label: {
                        ZStack {
                            Circle().fill(.ultraThinMaterial).frame(width: 36, height: 36)
                            Image(systemName: settingsVM.quietModeEnabled
                                  ? "bell.slash.fill" : "gearshape.fill")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(settingsVM.quietModeEnabled
                                    ? Color(red:1,green:0.27,blue:0.23) : .white.opacity(0.8))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 16).padding(.top, 8)
                }
                Spacer()
            }.zIndex(3)
        }
        .animation(.easeInOut(duration: 0.2), value: webVM.isLoading)
        .animation(.easeInOut(duration: 0.2), value: webVM.hasError)
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(settingsVM)
        }
        .onChange(of: settingsVM.quietModeEnabled) { _, enabled in
            webVM.applyQuietMode(enabled: enabled)
        }
    }
}
