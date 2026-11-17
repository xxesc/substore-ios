import SwiftUI

struct RootView: View {
    @EnvironmentObject private var config: AppConfig

    @State private var progress: Double = 0
    @State private var loaded = false
    @State private var showSettings = false
    @State private var reloadToken = UUID()

    private let brand = Color(red: 0.26, green: 0.72, blue: 0.51)

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            if config.isConfigured {
                PanelWebView(reloadToken: reloadToken,
                             progress: $progress,
                             onFirstLoad: {
                                 withAnimation(.easeOut(duration: 0.4)) { loaded = true }
                             })
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.opacity)
            }

            // 顶部细进度条
            VStack(spacing: 0) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Color.clear
                        if progress < 1 {
                            Rectangle()
                                .fill(brand)
                                .frame(width: max(0, geo.size.width * progress), height: 2.5)
                                .animation(.easeOut(duration: 0.25), value: progress)
                        }
                    }
                }
                .frame(height: 2.5)
                Spacer()
            }
            .ignoresSafeArea()

            if config.isConfigured && !loaded {
                SplashView(brand: brand)
                    .transition(.opacity)
            }

            if !config.isConfigured {
                EmptyStateView(brand: brand) { showSettings = true }
            }
        }
        .overlay(alignment: .topTrailing) {
            if config.isConfigured {
                controlCluster
                    .padding(.top, 6)
                    .padding(.trailing, 8)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(config)
        }
    }

    private var controlCluster: some View {
        Menu {
            Button {
                reloadToken = UUID()
            } label: {
                Label("刷新", systemImage: "arrow.clockwise")
            }
            Button {
                showSettings = true
            } label: {
                Label("设置", systemImage: "gearshape")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.85))
                .frame(width: 34, height: 34)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.18), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
        }
        .opacity(0.85)
    }
}

struct SplashView: View {
    let brand: Color

    var body: some View {
        ZStack {
            (Color(uiColor: .systemBackground)).ignoresSafeArea()
            VStack(spacing: 18) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 14, y: 6)

                Text("Sub-Store")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))

                Text("订阅管理")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                ProgressView()
                    .tint(brand)
                    .padding(.top, 4)
            }
        }
    }
}

struct EmptyStateView: View {
    let brand: Color
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 4)

            Text("还没连接面板")
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            Text("填入面板地址与 Basic 认证账号，一次配置后免登录进入")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: action) {
                Text("开始配置")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 11)
                    .background(brand, in: Capsule())
                    .foregroundStyle(.white)
            }
            .padding(.top, 6)
        }
    }
}
