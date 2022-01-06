//
//  SharedUserDefaultsAuthStateRepository.swift
//  SharedAppAuthState
//
//  Created by Thomas Asheim Smedmann on 30/12/2021.
//

import Foundation
import AppAuth

/**
 Sharing access to keychain items among a collection of apps:
 https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps
 
 Access shared UserDefaults:
 https://developer.apple.com/documentation/foundation/userdefaults/1409957-init
 
 Encode and decode objects for persistence:
 https://developer.apple.com/documentation/foundation/nskeyedarchiver
 https://developer.apple.com/documentation/foundation/nskeyedunarchiver
 */
final class SharedUserDefaultsAuthStateRepository {
    private let authStateKey = "authState"
    private let sharedUserDefaults: UserDefaults
    
    private var cachedState: OIDAuthState?
    
    init(appGroupIdentifier: String) {
        guard let sharedUserDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            fatalError("No access to shared UserDefaults")
        }
        self.sharedUserDefaults = sharedUserDefaults
    }
}

extension SharedUserDefaultsAuthStateRepository: AuthStateRepository {
    var state: OIDAuthState? {
        if let state = cachedState {
            return state
        }
        
        guard let data = sharedUserDefaults.data(forKey: authStateKey) else {
            return nil
        }
        
        guard let state = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? OIDAuthState else {
            print("Somehow failed to retrieve AuthState")
            return nil
        }
        
        cachedState = state
        
        return state
    }
    
    func persist(state: OIDAuthState) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: state, requiringSecureCoding: true)
        sharedUserDefaults.set(data, forKey: authStateKey)
    }
    
    func clear() {
        cachedState = nil
        sharedUserDefaults.removeObject(forKey: authStateKey)
    }
}
