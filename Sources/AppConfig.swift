import Foundation
import Security

/// 面板地址、账号、密码。密码存 Keychain，其余存 UserDefaults。
final class AppConfig: ObservableObject {
    static let shared = AppConfig()

    @Published var baseURL: String
    @Published var username: String
    @Published var password: String

    private let urlKey = "baseURL"
    private let userKey = "username"
    private let keychainService = "app.squirrel2391.cherry3073.substore"
    private let keychainAccount = "panel"

    var isConfigured: Bool {
        !baseURL.isEmpty && URL(string: baseURL) != nil && !password.isEmpty
    }

    init() {
        baseURL = UserDefaults.standard.string(forKey: urlKey) ?? "https://ss.zlf.de5.net/"
        username = UserDefaults.standard.string(forKey: userKey) ?? "admin"
        password = Keychain.read(service: keychainService, account: keychainAccount) ?? ""
    }

    func save() {
        UserDefaults.standard.set(baseURL, forKey: urlKey)
        UserDefaults.standard.set(username, forKey: userKey)
        if Keychain.read(service: keychainService, account: keychainAccount) != password {
            Keychain.delete(service: keychainService, account: keychainAccount)
            _ = Keychain.save(password, service: keychainService, account: keychainAccount)
        }
        objectWillChange.send()
    }

    func reset() {
        baseURL = "https://ss.zlf.de5.net/"
        username = "admin"
        password = ""
        UserDefaults.standard.set(baseURL, forKey: urlKey)
        UserDefaults.standard.set(username, forKey: userKey)
        Keychain.delete(service: keychainService, account: keychainAccount)
        objectWillChange.send()
    }
}

enum Keychain {
    static func save(_ value: String, service: String, account: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary)
        var add = query
        add[kSecValueData as String] = data
        return SecItemAdd(add as CFDictionary, nil) == errSecSuccess
    }

    static func read(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
