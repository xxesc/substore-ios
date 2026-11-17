import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var config: AppConfig
    @Environment(\.dismiss) private var dismiss

    private let brand = Color(red: 0.26, green: 0.72, blue: 0.51)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    card {
                        VStack(alignment: .leading, spacing: 12) {
                            fieldLabel("面板地址")
                            TextField("https://example.com/", text: $config.baseURL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                                .font(.system(size: 15, design: .monospaced))
                        }
                    }

                    card {
                        VStack(alignment: .leading, spacing: 14) {
                            fieldLabel("Basic 认证")
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 18)
                                TextField("用户名", text: $config.username)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                            Divider()
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 18)
                                SecureField("密码", text: $config.password)
                            }
                        }
                    }

                    footer

                    Button {
                        config.save()
                        dismiss()
                    } label: {
                        Text("保存并打开")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                config.baseURL.isEmpty || config.password.isEmpty
                                ? AnyShapeStyle(Color.gray.opacity(0.25))
                                : AnyShapeStyle(brand),
                                in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                            )
                            .foregroundStyle(.white)
                    }
                    .disabled(config.baseURL.isEmpty || config.password.isEmpty)

                    Button("清空配置") {
                        config.reset()
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(.red.opacity(0.85))
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            Text("连接你的 Sub-Store")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Text("凭据保存在本机 Keychain，不上传任何地方")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
    }

    private var footer: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.top, 1)
            Text("地址填到域名根路径即可，例如 https://ss.example.com/。App 会自动以同源方式连接后端，不需要再单独填 API 路径。")
                .font(.system(size: 11.5))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
    }
}
