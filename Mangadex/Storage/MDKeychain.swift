//
// Created by John Rion on 2021/7/3.
//

import Foundation

struct Credential {
    var username: String
    var password: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

class MDKeychain {
    private static let server = "mangadex.org"

    static func add(username: String,
                    password: String,
                    onSuccess success: () -> Void,
                    onError error: ((_ error: KeychainError) -> Void)?) {
        let passwordData = password.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: username,
            kSecAttrServer as String: server,
            kSecValueData as String: passwordData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if (status == errSecSuccess) {
            success()
        } else {
            if (error != nil) {
                error!(KeychainError.unhandledError(status: status))
            }
        }
    }

    static func read() -> [Credential] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var items: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        guard status == errSecSuccess else { return [] }

        let result = items as? Array<Dictionary<String, Any>>
        var values = [Credential]()
        for item in result! {
            if let username = item[kSecAttrAccount as String] as? String,
               let passwordData = item[kSecValueData as String] as? Data {
                values.append(Credential(username: username, password: String(data: passwordData, encoding: .utf8)!))
            }
        }
        return values
    }
}