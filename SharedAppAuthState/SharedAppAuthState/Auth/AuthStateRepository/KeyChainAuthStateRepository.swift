//
//  KeyChainAuthStateRepository.swift
//  SharedAppAuthState
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import Foundation
import Security
import AppAuth

/**
 Using the keychain to manage user secrets:
 https://developer.apple.com/documentation/security/keychain_services/keychain_items/using_the_keychain_to_manage_user_secrets
 
 Searching for keychain items:
 https://developer.apple.com/documentation/security/keychain_services/keychain_items/searching_for_keychain_items
 
 Sharing access to keychain items among a collection of apps:
 https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps
 
 Encode and decode objects for persistence:
 https://developer.apple.com/documentation/foundation/nskeyedarchiver
 https://developer.apple.com/documentation/foundation/nskeyedunarchiver
 */
final class KeyChainAuthStateRepository {
    private let migrationRepository: AuthStateRepository
    private let secureItemDescription = "Auth state"
    private let accessGroup: String
    private let accountName: String
    private let serviceName: String
    
    private var cachedState: OIDAuthState?
    
    private lazy var searchQuery = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccessGroup: accessGroup,
        kSecAttrService: serviceName,
        kSecAttrAccount: accountName,
        kSecMatchLimit: kSecMatchLimitOne,
        kSecReturnData: true,
        kSecReturnAttributes: true,
    ] as CFDictionary
    
    private lazy var basicSearchQuery = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccessGroup: accessGroup,
        kSecAttrService: serviceName,
        kSecAttrAccount: accountName,
    ] as CFDictionary
    
    init(accessGroup: String, serviceName: String, accountName: String, migrationRepository: AuthStateRepository) {
        self.accessGroup = accessGroup
        self.serviceName = serviceName
        self.accountName = accountName
        self.migrationRepository = migrationRepository
    }
}

extension KeyChainAuthStateRepository: AuthStateRepository {
    var state: OIDAuthState? {
        if let state = cachedState {
            return state
        }
        
        if let migratedState = migrationRepository.state {
            do {
                try persist(state: migratedState)
                cachedState = migratedState
                migrationRepository.clear()
                return migratedState
            } catch {
                print("Somehow failed to retrieve migrated AuthState")
            }
        }
        
        var item: CFTypeRef?
        
        let status = SecItemCopyMatching(searchQuery, &item)
        
        if status == errSecItemNotFound {
            print("No stored AuthState")
            return nil
        }
        
        guard
            status == errSecSuccess,
            let dictionary = item as? [CFString : Any],
            let creationDate = dictionary[kSecAttrCreationDate] as? Date,
            let modificationDate = dictionary[kSecAttrModificationDate] as? Date,
            let data = dictionary[kSecValueData] as? Data,
            let state = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? OIDAuthState
        else {
            print("Somehow failed to retrieve AuthState")
            return nil
        }
        
        print("AuthState retrieved. creationDate: \(creationDate), modificationDate: \(modificationDate)")
        
        cachedState = state
        
        return state
    }
    
    func persist(state: OIDAuthState) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: state, requiringSecureCoding: true)
        
        let attributes = [
            kSecValueData: data,
            kSecAttrDescription: secureItemDescription
        ] as CFDictionary
        
        var status = SecItemUpdate(basicSearchQuery, attributes)
        
        if status == errSecItemNotFound {
            let attributes = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccessGroup: accessGroup,
                kSecAttrService: serviceName,
                kSecAttrAccount: accountName,
                kSecValueData: data,
                kSecAttrDescription: secureItemDescription
            ] as CFDictionary
            
            status = SecItemAdd(attributes, nil)
        }
        
        if status != errSecSuccess {
            throw AuthError.failedToPersistState
        } else {
            cachedState = state
        }
    }
    
    func clear() {
        cachedState = nil
        let status = SecItemDelete(basicSearchQuery)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            return print("Somehow failed to clear AuthState")
        }
    }
}
