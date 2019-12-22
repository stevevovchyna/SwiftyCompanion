//
//  KeychainManager.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 19.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import Foundation

class KeychainManager {
    func save(_ token: String, for account: String) {
        let token = token.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecValueData as String: token]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { return print("keychain save error") }
    }
    
    func updateToken(_ token: String, for account: String) {
        let token = token.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: account]
        let attirbute: [String: Any] = [kSecValueData as String: token]
        let status = SecItemUpdate(query as CFDictionary, attirbute as CFDictionary)
        guard status == errSecSuccess else { return print("keychain update error", status) }
    }
        
    func retrieveToken(for account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: kCFBooleanTrue!]
        
        var retrivedData: AnyObject? = nil
        let _ = SecItemCopyMatching(query as CFDictionary, &retrivedData)
        
        guard let data = retrivedData as? Data else {return nil}
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func deleteToken(for account: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { return print("keychain delete error") }
        
    }
    
}

