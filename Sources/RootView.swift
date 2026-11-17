import SwiftUI
import WebKit

struct RootView: View {
    @EnvironmentObject private var config: AppConfig

    @State private var progress: Double = 0
    @State private var loaded = false
    @State private var showSettings = false
    @State private var reloadToken = UUID()
    @State private var expanded = false
    @State private var webRef: WKWebView?
    @Namespace private var glassNS

    private let brand = Color(red: 0.26, green: 0.72, blue: 0.51)

    private func triggerSearch() {
        webRef?.evaluateJavaScript(
            "var b=document.querySelector('.navBar-left-icon--search'); if(b){b.click();}"
        )
    }

    var body: some View {
        ZStack {
            brandMesh.ignoresSafeArea()

            if config.isConfigured {
                PanelWebView(reloadToken: reloadToken,
                         progress: $progress,
                         onFirstLoad: {
                             withAnimation(.easeOut(duration: 0.45)) { loaded = true }
                         },
                         onWebViewReady: { web in webRef = web })
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.opacity)
            }

            // 顶部加载进度条
            VStack(spacing: 0) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Color.clear
                        if progress < 1 {
                            Capsule()
                                .fill(brand)
                                .frame(width: max(0, geo.size.width * progress), height: 3)
                                .animation(.easeOut(duration: 0.25), value: progress)
                        }
                    }
                    .padding(.horizontal, 0)
                }
                .frame(height: 3)
                Spacer()
            }
            .ignoresSafeArea()

            if config.isConfigured && !loaded {
                SplashView(brand: brand)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }

            if !config.isConfigured {
                EmptyStateView(brand: brand) { showSettings = true }
                    .transition(.opacity)
            }
        }
        .overlay(alignment: .topTrailing) {
            if config.isConfigured {
                controlCluster
                    .padding(.top, 8)
                    .padding(.trailing, 12)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(config)
        }
        .tint(brand)
    }

    private var brandMesh: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            RadialGradient(colors: [brand.opacity(0.28), .clear],
                           center: .topLeading, startRadius: 20, endRadius: 520)
            RadialGradient(colors: [Color.blue.opacity(0.18), .clear],
                           center: .bottomTrailing, startRadius: 20, endRadius: 620)
        }
    }

    // MARK: - 液态玻璃控制组

    private var controlCluster: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 10) {
                if expanded {
                    Button {
                        reloadToken = UUID()
                        withAnimation(.bouncy(duration: 0.35)) { expanded = false }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: Circle())
                    .glassEffectID("refresh", in: glassNS)
                    .transition(.scale.combined(with: .opacity))

                    Button {
                        withAnimation(.bouncy(duration: 0.35)) { expanded = false }
                        triggerSearch()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: Circle())
                    .glassEffectID("search", in: glassNS)
                    .transition(.scale.combined(with: .opacity))

                    Button {
                        withAnimation(.bouncy(duration: 0.35)) { expanded = false }
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: Circle())
                    .glassEffectID("settings", in: glassNS)
                    .transition(.scale.combined(with: .opacity))
                }

                Button {
                    withAnimation(.bouncy(duration: 0.4)) { expanded.toggle() }
                } label: {
                    Image(systemName: expanded ? "xmark" : "ellipsis")
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 34, height: 34)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: Circle())
                .glassEffectID("toggle", in: glassNS)
            }
        }
    }
}

// MARK: - 启动闪屏

struct SplashView: View {
    let brand: Color

    var body: some View {
        ZStack {
            ZStack {
                Color(uiColor: .systemBackground)
                RadialGradient(colors: [brand.opacity(0.35), .clear],
                               center: .top, startRadius: 10, endRadius: 420)
            }
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                VStack(spacing: 6) {
                    Text("Sub-Store")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("订阅管理")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                ProgressView()
                    .controlSize(.regular)
                    .tint(brand)
                    .padding(.top, 6)
            }
        }
    }
}

// MARK: - 未配置空状态

struct EmptyStateView: View {
    let brand: Color
    let action: () -> Void

    var body: some View {
        VStack {
            GlassEffectContainer(spacing: 20) {
                VStack(spacing: 18) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))

                    VStack(spacing: 8) {
                        Text("还没连接面板")
                            .font(.system(size: 19, weight: .semibold, design: .rounded))
                        Text("填入面板地址与 Basic 认证账号\n一次配置后免登录进入")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }

                    Button(action: action) {
                        Text("开始配置")
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.horizontal, 26)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(brand)
                }
                .padding(28)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            }
            .padding(.horizontal, 34)
        }
    }
}
