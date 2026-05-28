//
// Created by John Rion on 2021/7/3.
//

import Foundation

struct Credential: Codable, Sendable {
    var username: String
    var session: String
    var refresh: String
}

enum KeychainError: Error {
    case unhandledError(status: OSStatus)
}

class MDKeychain {
    private static let server = "mangadex.org"

    static func save(
        username: String,
        session: String,
        refresh: String
    ) throws {
        let credential = Credential(
            username: username,
            session: session,
            refresh: refresh
        )
        let data = try JSONEncoder().encode(credential)
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: username,
            kSecAttrServer as String: server
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        let addQuery = query + attributes

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status == errSecSuccess {
            return
        }

        if status == errSecDuplicateItem {
            let updateStatus = SecItemUpdate(
                query as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unhandledError(status: updateStatus)
            }
            return
        }

        throw KeychainError.unhandledError(status: status)
    }

    static func delete(username: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: username,
            kSecAttrServer as String: server
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
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
        guard let result = items as? Array<Dictionary<String, Any>> else {
            return []
        }

        return result.compactMap { item in
            guard
                let data = item[kSecValueData as String] as? Data
            else {
                return nil
            }
            if let credential = try? JSONDecoder().decode(Credential.self, from: data) {
                return credential
            }

            return nil
        }
    }
}
