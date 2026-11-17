import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var config: AppConfig
    @Environment(\.dismiss) private var dismiss

    private let brand = Color(red: 0.26, green: 0.72, blue: 0.51)

    var body: some View {
        NavigationStack {
            ZStack {
                mesh.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header
                        GlassEffectContainer(spacing: 18) {
                            VStack(spacing: 18) {
                                urlCard
                                authCard
                                footerCard
                            }
                        }
                        primaryButton
                        resetButton
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 6)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .tint(brand)
        }
    }

    private var mesh: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            RadialGradient(colors: [brand.opacity(0.30), .clear],
                           center: .topLeading, startRadius: 20, endRadius: 460)
            RadialGradient(colors: [Color.blue.opacity(0.20), .clear],
                           center: .bottomTrailing, startRadius: 20, endRadius: 520)
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(spacing: 5) {
                Text("连接你的 Sub-Store")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text("凭据存在本机 Keychain，不上传")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    private var urlCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            label("面板地址", icon: "link")
            TextField("https://example.com/", text: $config.baseURL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .font(.system(size: 15, design: .monospaced))
                .padding(.vertical, 11)
                .padding(.horizontal, 13)
                .background(.quaternary.opacity(0.35),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(18)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var authCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            label("Basic 认证", icon: "key.fill")

            HStack(spacing: 10) {
                Image(systemName: "person.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
                TextField("用户名", text: $config.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 13)
            .background(.quaternary.opacity(0.35),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
                SecureField("密码", text: $config.password)
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 13)
            .background(.quaternary.opacity(0.35),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(18)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var footerCard: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 13))
                .foregroundStyle(brand)
                .padding(.top, 1)
            Text("地址填到域名根路径即可，例如 https://ss.example.com/。App 自动以同源方式连接后端，不需要再单独填 API 路径。")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineSpacing(2)
        }
        .padding(16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var primaryButton: some View {
        Button {
            config.save()
            dismiss()
        } label: {
            Text("保存并打开")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
        }
        .buttonStyle(.glassProminent)
        .tint(brand)
        .disabled(config.baseURL.isEmpty || config.password.isEmpty)
        .opacity(config.baseURL.isEmpty || config.password.isEmpty ? 0.45 : 1)
    }

    private var resetButton: some View {
        Button("清空配置") {
            config.reset()
        }
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(.red.opacity(0.85))
        .buttonStyle(.glass)
    }

    private func label(_ text: String, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(brand)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }
}
