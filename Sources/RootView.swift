import SwiftUI

struct RootView: View {
    @EnvironmentObject private var config: AppConfig
    @State private var showSettings = false
    @State private var reloadToken = UUID()

    var body: some View {
        NavigationStack {
            Group {
                if config.isConfigured {
                    PanelWebView(reloadToken: reloadToken)
                        .ignoresSafeArea(edges: .bottom)
                        .navigationTitle("Sub-Store")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    reloadToken = UUID()
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                }
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showSettings = true
                                } label: {
                                    Image(systemName: "gearshape")
                                }
                            }
                        }
                } else {
                    ContentUnavailableView {
                        Label("还没配置面板", systemImage: "link.badge.plus")
                    } description: {
                        Text("填入 Sub-Store 地址和 Basic 认证账号")
                    } actions: {
                        Button("去配置") { showSettings = true }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(config)
            }
        }
    }
}
