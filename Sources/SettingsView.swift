import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var config: AppConfig
    @Environment(\.dismiss) private var dismiss
    @State private var saved = false

    var body: some View {
        NavigationStack {
            Form {
                Section("面板地址") {
                    TextField("https://…", text: $config.baseURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Basic 认证") {
                    TextField("用户名", text: $config.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("密码", text: $config.password)
                }

                Section {
                    Button("保存并打开") {
                        config.save()
                        saved = true
                        dismiss()
                    }
                    .disabled(config.baseURL.isEmpty || config.password.isEmpty)

                    Button("恢复默认地址", role: .destructive) {
                        config.reset()
                    }
                } footer: {
                    Text("凭据保存在本机 Keychain，仅用于自动应答面板的 Basic 认证。")
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}
