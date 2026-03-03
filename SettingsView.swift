import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    private let blue  = Color(red:0.04,green:0.52,blue:1)
    private let red   = Color(red:1,green:0.27,blue:0.23)
    private let green = Color(red:0.19,green:0.82,blue:0.35)

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing:16) {
                        RoundedRectangle(cornerRadius:8)
                            .fill(settingsVM.quietModeEnabled ? red : Color(white:0.17))
                            .frame(width:34,height:34)
                            .overlay {
                                Image(systemName: settingsVM.quietModeEnabled
                                      ? "bell.slash.fill" : "bell.fill")
                                    .font(.system(size:16)).foregroundStyle(.white)
                            }
                        VStack(alignment:.leading,spacing:3) {
                            Text("Quiet Mode")
                                .font(.system(size:17,weight:.medium)).foregroundStyle(.white)
                            Text("Mutes incoming voice messages")
                                .font(.system(size:13)).foregroundStyle(.white.opacity(0.5))
                        }
                        Spacer()
                        Toggle("",isOn:$settingsVM.quietModeEnabled).labelsHidden().tint(blue)
                    }.padding(.vertical,4)
                } header: { Text("Audio") }
                  footer: {
                    Text(settingsVM.quietModeEnabled
                        ? "Incoming audio muted. Transmissions unaffected. Independent of system DND."
                        : "Incoming PTT messages play normally.").foregroundStyle(.white.opacity(0.4))
                }

                Section {
                    HStack(spacing:16) {
                        RoundedRectangle(cornerRadius:8).fill(green.opacity(0.15))
                            .frame(width:34,height:34)
                            .overlay {
                                Image(systemName:"checkmark.circle.fill")
                                    .font(.system(size:16)).foregroundStyle(green)
                            }
                        VStack(alignment:.leading,spacing:3) {
                            Text("Background Audio")
                                .font(.system(size:17,weight:.medium)).foregroundStyle(.white)
                            Text("Active — plays through lock screen")
                                .font(.system(size:13)).foregroundStyle(green)
                        }
                    }.padding(.vertical,4)
                } footer: {
                    Text("PTT audio continues when the device is locked.")
                        .foregroundStyle(.white.opacity(0.4))
                }

                Section("About") {
                    HStack {
                        Text("Version").foregroundStyle(.white.opacity(0.7)); Spacer()
                        Text("1.0.0 (1)").foregroundStyle(.white.opacity(0.4))
                    }
                    HStack {
                        Text("Platform").foregroundStyle(.white.opacity(0.7)); Spacer()
                        Text("iOS \(UIDevice.current.systemVersion)").foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            .scrollContentBackground(.hidden).background(Color.black)
            .navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement:.topBarTrailing) {
                    Button("Done"){dismiss()}.foregroundStyle(blue).fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium,.large]).presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }
}
